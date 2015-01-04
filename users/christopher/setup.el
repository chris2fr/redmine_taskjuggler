;; This buffer is for notes you don't want to save, and for Lisp evaluation.
;; If you want to create a file, visit that file with C-x C-f,
;; then enter the text in that file's own buffer.

(require 'org-publish)
(setq org-publish-project-alist
  '(("taskjuggler-org"
    :base-directory "c:/c_share/c/redmine_taskjuggler/doc/taskjuggler.net/org/"
    :publishing-directory "c:/c_share/c/redmine_taskjuggler/doc/taskjuggler.net/www/"
    :recursive t
    :base-extension "org"
    :section-numbers nil
    :with-toc nil
    :publishing-function org-publish-org-to-html  ; Tells org to convert the org files to html.
    :style "<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/stylesheet.css\" />" ; Includes the CSS file for page setup
    :html-preamble ""
    ;:html-postamble "<HR/>"
    :export-creator-info nil    ; Disable the inclusion of "Created by Org".
    :auto-sitemap t
 
    )
    ("taskjuggler-static"
    :base-directory "c:/c_share/c/redmine_taskjuggler/doc/taskjuggler.net/org/"
    :publishing-directory "c:/c_share/c/redmine_taskjuggler/doc/taskjuggler.net/www/"
    :recursive t
    :base-extension "css\\|jpg\\|png\\|pdf"
    :publishing-function org-publish-attachment
    )

    ("taskjuggler" :components ("taskjuggler-org" "taskjuggler-static")) ; If you export project "home", both "home-html" and "home-static" will be exported.

  ))


