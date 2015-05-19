<%inherit file="project/project_base.mako"/>

## Use full page width
<%def name="container_class()">container-xxl</%def>

<%def name="title()">${file_name | h}</%def>
    <div class="row">
        <div class="col-sm-6">
            <h2 class="break-word">
                ${file_name | h}
                % if file_revision:
                    <small>&nbsp;${file_revision | h}</small>
                % endif
            </h2>
        </div>
        <div class="col-sm-6">
            <div class="pull-right">
                <div class="switch"></div>
            </div>
        </div>
    </div>

    <div id="file-container" class="row">

    <div id="file-navigation" class="panel-toggle col-md-3">
        <div class="osf-panel osf-panel-flex hidden-xs reset-height">
            <div class="osf-panel-header osf-panel-header-flex" style="display:none">
                <div id="filesSearch"></div>
                <div id="toggleIcon" class="pull-right">
                    <div class="panel-collapse"> <i class="fa fa-angle-left"> </i> </div>
                </div>
            </div>

            <div class="osf-panel-body osf-panel-body-flex file-page reset-height">
                <div id="grid">
                    <div class="fangorn-loading"> <i class="fa fa-spinner fangorn-spin"></i> <p class="m-t-sm fg-load-message"> Loading files...  </p> </div>
                </div>
            </div>
        </div>

    <!-- Menu toggle closed -->
        <div class="osf-panel panel-collapsed hidden-xs text-center reset-height"  style="display: none">
            <div class="osf-panel-header">
                <i class="fa fa-file"> </i>
                <i class="fa fa-angle-right"> </i>
            </div>
        </div>
    </div>

    <div class="panel-expand col-md-6">
        <div id="fileRendered" class="mfr mfr-file">

        % if user['can_edit'] and file_ext == '.txt':
            <div class="wiki" id="filePageContext">
                <div data-bind="with: $root.editVM.wikiEditor.viewModel" data-osf-panel="Edit" style="display: none">
                    <div class="osf-panel" >
                        <div class="osf-panel-header" >
                            <div class="wiki-panel">
                                <div class="wiki-panel-header">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <span class="wiki-panel-title" > <i class="fa fa-pencil-square-o"></i>   Edit </span>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="pull-right">
                                                <div class="progress progress-no-margin pointer " data-toggle="modal" data-bind="attr: {data-target: modalTarget}" >
                                                    <div role="progressbar"data-bind="attr: progressBar">
                                                        <span class="progress-bar-content">
                                                            <span data-bind="text: statusDisplay"></span>
                                                            <span class="sharejs-info-btn"><i class="fa fa-question-circle fa-large"></i></span>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <form id="file-edit-form">
                            <div class="wiki-panel-body" style="padding: 10px">
                                <div class="row">
                                    <div class="col-xs-12">
                                        <div class="form-group wmd-panel">
                                            <div id="wmd-button-bar"></div>
                                            <div id="editor" class="wmd-input wiki-editor" data-bind="ace: currentText">Loading. . .</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="wiki-panel-footer">
                                <div class="row">
                                    <div class="col-xs-12">
                                        <div class="pull-right">
                                            <button id="revert-button" class="btn btn-danger" data-bind="click: revertChanges">Revert</button>
                                            <input type="submit" class="btn btn-success" value="Save" id="submitEdit">
                                        </div>
                                    </div>
                                </div>

                                <!-- Invisible textarea for form submission -->
                                <textarea id="original_content" style="display: none;">${content}</textarea>
                                <textarea id="edit_content" style="display: none;" data-bind="value: currentText"></textarea>

                            </div>
                        </form>
                    </div>
                </div>

        % else:
            % if rendered is not None:
                ${rendered}
            % else:
                <img src="/static/img/loading.gif">
            % endif
        % endif

        </div>
    </div>

    % if user['can_edit'] and file_ext == '.txt':
    <div data-osf-panel="View">
        <div class="osf-panel" data-bind="css: { 'no-border reset-height': $root.singleVis() === 'view', 'osf-panel-flex': $root.singleVis() !== 'view' }">
            <div class="osf-panel-header bordered" data-bind="css: { 'osf-panel-header-flex': $root.singleVis() !== 'view', 'bordered': $root.singleVis() === 'view' }">
                <div class="row">
                    <div class="col-sm-6">
                        <span class="wiki-panel-title" > <i class="fa fa-eye"> </i>  View</span>
                    </div>
                </div>
            </div>

            <div id="wikiViewPanel"  class="osf-panel-body" data-bind="css: { 'osf-panel-body-flex': $root.singleVis() !== 'view' }">
                <div id="wikiViewRender" data-bind="html: renderedView, mathjaxify: renderedView, anchorScroll : { buffer: 50, elem : '#wikiViewPanel'}" class=" markdown-it-view">
                    % if content:
                        ${content}
                    % else:
                        <p><em>No file content</em></p>
                    % endif
                </div>
            </div>
        </div>
    </div>

    % endif
    </div>

    <div class="modal fade" id="connectedModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title">Connected to the collaborative wiki</h3>
                </div>
                <div class="modal-body">
                    <p>
                        This page is currently connected to the collaborative wiki. All edits made will be visible to
                        contributors with write permission in real time. Changes will be stored
                        but not published until you click the "Save" button.
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="connectingModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title">Connecting to the collaborative wiki</h3>
                </div>
                <div class="modal-body">
                    <p>
                        This page is currently attempting to connect to the collaborative wiki. You may continue to make edits.
                        <strong>Changes will not be saved until you press the "Save" button.</strong>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="disconnectedModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title">Collaborative wiki is unavailable</h3>
                </div>
                <div class="modal-body">
                    <p>
                        The collaborative wiki is currently unavailable. You may continue to make edits.
                        <strong>Changes will not be saved until you press the "Save" button.</strong>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="unsupportedModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h3 class="modal-title">Browser unsupported</h3>
                </div>
                <div class="modal-body">
                    <p>
                        Your browser does not support collaborative editing. You may continue to make edits.
                        <strong>Changes will not be saved until you press the "Save" button.</strong>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div id="fileRevisions" class="scripted">
          <ol class="breadcrumb">
            <li><a href="{{ node.urls.files }}" data-bind="text: node.title"></a></li>
            <li class="active overflow" data-bind="text: file.provider"></li>
            <!-- ko foreach: path.slice(1) -->
            <li class="active overflow" data-bind="text: $data"></li>
            <!-- /ko -->
          </ol>

          <span data-bind="if: currentVersion">
            <a class="btn btn-success btn-md file-download" href="{{ currentVersion().osfDownloadUrl }}" data-bind="click: currentVersion().download">
              Download <i class="fa fa-download"></i>
            </a>
          </span>

          <span data-bind="if: editable">
            <button class="btn btn-danger btn-md file-delete" data-bind="click: askDelete">
              Delete <i class="fa fa-trash-o"></i>
            </button>
          </span>


          <table class="table" data-bind="if: versioningSupported && revisions().length">
            <thead class="file-version-thread">
              <tr>
                <th width="10%">Version ID</th>
                <th data-bind="if: hasDate">Date</th>
                <th data-bind="if: userColumn">User</th>
                <th colspan="2">Download</th>
                <th></th>
              </tr>
            </thead>

            <tbody class="file-version" data-bind="foreach: {data: revisions, as: 'revision'}">
              <tr data-bind="css: $parent.isActive(revision)">
                <td>
                  <a href="{{ revision.osfViewUrl }}" data-bind="if: revision !== $parent.currentVersion()">
                    {{ revision.displayVersion }}
                  </a>
                  <span data-bind="if: revision === $parent.currentVersion()">
                    {{ revision.displayVersion }}
                  </span>
                </td>
                <td data-bind="if: $parent.hasDate">{{ revision.displayDate }}</td>
                <td data-bind="if: $parent.userColumn">
                  <a data-bind="if: revision.extra.user.url"
                    href="{{ revision.extra.user.url }}">
                    {{ revision.extra.user.name }}
                  </a>
                  <span data-bind="ifnot: revision.extra.user.url">
                    {{ revision.extra.user.name }}
                  </span>
                </td>
                <td>
                  <span class="badge" data-bind="if: revision.extra.downloads !== undefined">
                    {{ revision.extra.downloads }}
                  </span>
                </td>
                <td>
                  <a class="btn btn-primary btn-sm file-download" href="{{ revision.osfDownloadUrl }}"
                    data-bind="click: revision.download">
                    <i class="fa fa-download"></i>
                  </a>
                </td>
              </tr>
            </tbody>
          </table>

          <div data-bind="ifnot: versioningSupported">
            <hr>
            <div class="alert alert-warning" role="alert">
              {{ errorMessage }}
            </div>
          </div>

        </div>
      </div>
    </div>


<%def name="javascript_bottom()">
<% import json %>
    ${parent.javascript_bottom()}
    % for script in tree_js:
        <script type="text/javascript" src="${script | webpack_asset}"></script>
    % endfor

    % if 'osf.io' in domain:
    <script>
        // IE10 Same Origin (CORS) fix
        document.domain = 'osf.io';
    </script>
    %endif
    <script type="text/javascript">
      var isEditable = false;
      % if user['can_edit'] and file_ext == '.txt':
          isEditable = true;
      % endif
      window.contextVars = $.extend(true, {}, window.contextVars, {
        %if rendered is None:
            renderURL: '${render_url | js_str}',
        %else:
            renderURL: undefined,
        %endif
            file: {
                extra: ${extra},
                name: '${file_name | js_str}',
                path: '${file_path | js_str}',
                provider: '${provider | js_str}',
                safeName: '${file_name | h,js_str}'
            },
            node: {
              urls: {
                files: '${files_url | js_str}'
              }
            },
            currentUser: {
              canEdit: ${int(user['can_edit'])}
            },
            files: {
                canEdit: ${json.dumps(user['can_edit'])},
                panelsUsed: ${json.dumps(panels_used) | n},
                isEditable: isEditable,
                urls: {
                    draft: '/api/v1' + '${files_url | js_str}' + '${provider | js_str}' + '${file_path | js_str}',
                    content: '/api/v1' + '${files_url | js_str}' + '${provider | js_str}' + '${file_path | js_str}',
                    rename: '/api/v1' + '${files_url | js_str}' + '${provider | js_str}' + '${file_path | js_str}',
                    page: '/api/v1' + '${files_url | js_str}' + '${provider | js_str}' + '${file_path | js_str}',
                    base: '/api/v1' + '${files_url | js_str}' + '${provider | js_str}' + '${file_path | js_str}',
                    sharejs: 'localhost:7007'
                }
            }
      });
    </script>

    <script>
        $('#submitEdit').on('click', function(e) {
            e.preventDefault();
            var editContent = $('#edit_content').val();
            var originalContent = $('#original_content').val();

            if (editContent != originalContent) {
                var request = $.ajax({
                    type: 'PUT',
                    url: '${edit_url}',
                    data: editContent
                });

                request.done(function () {
                    $.ajax({
                        type: 'GET',
                        url: '${view_url}'
                    }).done(function() {
                        window.location.href = '${view_url}';
                    });
                });

                request.fail(function(response) {
                   console.log('fail');
                });
            } else {
                alert("There are no changes to be saved.");
            }
        });
    </script>

    <script src="//localhost:7007/text.js"></script>
    <script src="//localhost:7007/share.js"></script>
    <script src=${"/static/public/js/file-edit-page.js" | webpack_asset}></script>
    <script src=${"/static/public/js/view-file-page.js" | webpack_asset}></script>
    <script src=${"/static/public/js/view-file-tree-page.js" | webpack_asset}></script>
</%def>
