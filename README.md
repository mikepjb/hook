# hook

Single file configuration for the Emacs editor.

Designed to be setup on any (windows/osx/linux) Emacs editor with a single line of elisp.

Simply open your Emacs, M-x eval-expression (or Alt + Shift + ;) and paste (with Ctrl + Y):

```
(url-copy-file
	"https://raw.githubusercontent.com/mikepjb/hook/master/init.el"
	(concat user-emacs-directory "init.el") t)
```
