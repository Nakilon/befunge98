[![Build Status](https://travis-ci.org/Nakilon/befunge98.png?)](https://travis-ci.org/Nakilon/befunge98)

There are a lot of Befunge-93 Ruby implementations in the wild but I don't see any Befunge-98.
So let it be the first one.

- [x] Befunge-93 (["Befunge-93 Documentation"](https://github.com/catseye/Befunge-93/blob/master/doc/Befunge-93.markdown))
- [x] memory size and code format edits
- [ ] Befunge-98 (["Funge-98 Final Specification"](https://github.com/catseye/Funge-98/blob/master/doc/funge98.markdown))
  - [ ] operations
    - [x] `q` -- quit <exit code>
    - [x] `a`-`f` -- push 10..15 onto stack
    - [x] `n` -- clear all stacks
    - [x] `'`, `s` -- fetch and store a char
    - [x] `;` -- comments
    - [x] `]`, `[`, `w`, `r`, `x` -- change delta
    - [x] `j` -- jump forward
    - [x] `k` -- iterate
    - [x] `{`, `}`, `u` -- push cells between TOSS and SOSS
    - [x] `(`, `)` -- we don't implement semantics
    - [ ] `y` -- what do 13th and 14th slots mean?
    - [ ] `z` -- can we just skip it?
  - [x] `y` specification allows us to skip these
    - [x] (execute) `=`
    - [x] (filesystem) `i`, `o`
    - [x] (concurrent) `t`
    - [x] (3D) `h`, `l`, `m`
- [ ] tests
  - [ ] bin
    - [x] Hello, World!
    - [ ] failures, ^C, hanging, etc.
  - [ ] operations
    - [x] Befunge-93
      - [x] `@`
      - [x] `"`
      - [x] `0`..`9`
      - [x] `$`, `:`, `\`
      - [x] `#`
      - [x] `>`, `<`, `^`, `v`, `?`
      - [x] `+`, `-`, `*`, `/`, `%`
      - [x] `|`, `_`
      - [x] `~`, `&`, `,`, `.`
      - [x] `!`, `` ` ``
      - [x] `p`, `g`
    - [ ] Befunge-98
      - [x] `~`, `&`
      - [x] `q`
      - [ ] `a`-`f`
      - [x] `n`
      - [x] `'`, `s`
      - [ ] `;`
      - [x] `w`
      - [ ] `]`, `[`, `w`, `r`, `x`
      - [x] `j`
      - [ ] `k`
      - [ ] `{`, `}`, `u`
      - [ ] `(`, `)`
      - [ ] `y`
      - [ ] ...
- [ ] Github Actions test
- [ ] gemify
- [ ] announce

This implementation in another language somewhat helped me: https://bitbucket.org/lifthrasiir/pyfunge/src/default/funge/languages/funge98.py

## GUI

### Glimmer DSL for SWT

![screenshot 1](/gui/glimmer-dsl-swt/befunge98_gui_glimmer_dsl_swt/screenshots/befunge98_gui_glimmer_dsl_swt_example.png)

![screenshot 2](/gui/glimmer-dsl-swt/befunge98_gui_glimmer_dsl_swt/screenshots/befunge98_gui_glimmer_dsl_swt_example_output.png)

[You may download a packaged version for the Mac (Big Sur x64 and earlier) from here](https://www.dropbox.com/s/4kqnlfh1ei328hn/Befunge98%20GUI-1.0.0.dmg?dl=1)

To run GUI from cloned project, browse into `gui/glimmer-dsl-swt/befunge98_gui_glimmer_dsl_swt`

Run:

```
bundle
```

Afterwards, run:
```
glimmer run
```

To package into a native executable ([learn more here](https://github.com/AndyObtiva/glimmer-dsl-swt/blob/master/docs/reference/GLIMMER_PACKAGING_AND_DISTRIBUTION.md)), run:
```
glimmer package
```
