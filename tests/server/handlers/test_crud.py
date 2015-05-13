import pytest

import json
import asyncio
from unittest import mock

from tornado import testing
from tornado import httpclient

from waterbutler.core import streams
from waterbutler.core import exceptions

from tests import utils


class TestCrudHandler(utils.HandlerTestCase):

    def setUp(self):
        super().setUp()
        identity_future = asyncio.Future()
        identity_future.set_result({
            'auth': {},
            'credentials': {},
            'settings': {},
        })
        self.mock_identity = mock.Mock()
        self.mock_identity.return_value = identity_future
        self.identity_patcher = mock.patch('waterbutler.server.handlers.core.get_identity', self.mock_identity)

        self.mock_provider = utils.MockProvider1({}, {}, {})
        self.mock_make_provider = mock.Mock(return_value=self.mock_provider)
        self.make_provider_patcher = mock.patch('waterbutler.core.utils.make_provider', self.mock_make_provider)

        self.identity_patcher.start()
        self.make_provider_patcher.start()

    def tearDown(self):
        super().tearDown()
        self.identity_patcher.stop()
        self.make_provider_patcher.stop()

    @testing.gen_test
    def test_download_redirect(self):
        redirect_url = 'http://queen.com/freddie.png'

        self.mock_provider.download = utils.MockCoroutine(return_value=redirect_url)

        with pytest.raises(httpclient.HTTPError) as exc:
            yield self.http_client.fetch(
                self.get_url('/file?provider=queenhub&path=/freddie.png'),
                follow_redirects=False,
            )
        assert exc.value.code == 302
        assert exc.value.response.headers.get('Location') == redirect_url
        calls = self.mock_provider.download.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'download'

    @testing.gen_test
    def test_download_stream(self):
        data = b'freddie brian john roger'
        stream = streams.StringStream(data)
        stream.content_type = 'application/octet-stream'
        self.mock_provider.download = utils.MockCoroutine(return_value=stream)

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/freddie.png'),
        )
        assert resp.body == data
        calls = self.mock_provider.download.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'download'

    @testing.gen_test
    def test_download_accept_url_false(self):
        data = b'freddie brian john roger'
        stream = streams.StringStream(data)
        stream.content_type = 'application/octet-stream'
        self.mock_provider.download = utils.MockCoroutine(return_value=stream)

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/freddie.png&accept_url=false'),
        )
        assert resp.body == data
        calls = self.mock_provider.download.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'download'
        assert kwargs.get('accept_url') is False

    @testing.gen_test
    def test_download_accept_url_default(self):
        data = b'freddie brian john roger'
        stream = streams.StringStream(data)
        stream.content_type = 'application/octet-stream'
        self.mock_provider.download = utils.MockCoroutine(return_value=stream)

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/freddie.png'),
        )
        assert resp.body == data
        calls = self.mock_provider.download.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'download'
        assert kwargs.get('accept_url') is True

    @testing.gen_test
    def test_download_accept_url_true(self):
        data = b'freddie brian john roger'
        stream = streams.StringStream(data)
        stream.content_type = 'application/octet-stream'
        self.mock_provider.download = utils.MockCoroutine(return_value=stream)

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/freddie.png&accept_url=true'),
        )
        assert resp.body == data
        calls = self.mock_provider.download.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'download'
        assert kwargs.get('accept_url') is True

    @testing.gen_test
    def test_download_accept_url_invalid(self):
        self.mock_provider.download = utils.MockCoroutine()

        with pytest.raises(httpclient.HTTPError) as exc:
            yield self.http_client.fetch(
                self.get_url('/file?provider=queenhub&path=/freddie.png&accept_url=teapot'),
            )
        assert exc.value.code == 400
        assert self.mock_provider.download.called is False

    @testing.gen_test
    def test_download_not_found(self):
        self.mock_provider.download = utils.MockCoroutine(side_effect=exceptions.NotFoundError('/freddie.png'))

        with pytest.raises(httpclient.HTTPError) as exc:
            yield self.http_client.fetch(
                self.get_url('/file?provider=queenhub&path=/freddie.png'),
            )

        assert exc.value.code == 404

    @testing.gen_test
    def test_upload(self):
        data = b'stone cold crazy'
        expected = {'path': 'roger.png'}
        self.mock_provider.upload = utils.MockCoroutine(return_value=(expected, True))

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/roger.png'),
            method='PUT',
            body=data,
        )

        calls = self.mock_provider.upload.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert isinstance(args[0], streams.RequestStreamReader)
        streamed = asyncio.new_event_loop().run_until_complete(args[0].read())
        assert streamed == data
        assert kwargs['action'] == 'upload'
        assert str(kwargs['path']) == '/roger.png'
        assert expected == json.loads(resp.body.decode())

    @testing.gen_test
    def test_delete(self):
        self.mock_provider.delete = utils.MockCoroutine()

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/john.png'),
            method='DELETE',
        )

        calls = self.mock_provider.delete.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'delete'
        assert resp.code == 204

    @testing.gen_test
    def test_create_folder(self):
        self.mock_provider.create_folder = utils.MockCoroutine(return_value={})

        resp = yield self.http_client.fetch(
            self.get_url('/file?provider=queenhub&path=/folder/'),
            method='POST',
            body=''
        )
        calls = self.mock_provider.create_folder.call_args_list
        assert len(calls) == 1
        args, kwargs = calls[0]
        assert kwargs.get('action') == 'create_folder'
        assert resp.code == 201
