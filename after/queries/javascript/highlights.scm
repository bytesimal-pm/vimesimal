; extends
; Same as after/queries/tsx/highlights.scm, for .js/.jsx files.

; The TSX grammar errors on "&" inside attribute strings, e.g.
; href="https://x.com/?a=1&b=2", and colors the rest as code. Keep the whole
; string colored as a string.
((string (ERROR) @string)
  (#set! priority 105))

; ...and when that string is a URL, keep the URL style across the whole thing
((string
  (string_fragment) @_url
  (ERROR) @string.special.url)
  (#lua-match? @_url "^https?://")
  (#set! priority 106))

; Text between tags is plain text. nvim-treesitter marks <h1> text as a
; heading, <code> as raw and <a> as a link, which reads as random colors.
((jsx_text) @none
  (#set! priority 105))
