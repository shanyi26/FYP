// FYP Report Template for NTU CCDS
// Based on NTU SCSE FYP guidelines
// Original LaTeX version by Vincent Ribli
// Revised by Prof Loy Chen Change (Aug 2024)
// Converted to Typst

#import "metadata.typ": *

// Page setup
#set page(
  paper: "a4",
  margin: (top: 3cm, bottom: 3cm, left: 3.5cm, right: 3cm),
)

// Font setup (Times-like serif font; change to "Times New Roman" if available)
#set text(font: "New Computer Modern", size: 12pt)

// Paragraph setup (1.5 line spacing, no first-line indent)
#set par(leading: 0.9em, first-line-indent: 0pt, spacing: 1.2em)

// Code block styling
#show raw.where(block: true): set block(
  fill: luma(245),
  stroke: 0.6pt + luma(200),
  inset: 10pt,
  radius: 6pt,
)

// Heading styles (chapter-like for level 1)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(2cm)
  align(center)[
    #if it.numbering != none {
      text(size: 16pt)[Chapter #counter(heading).display(it.numbering)]
      linebreak()
      v(0.3cm)
    }
    #text(size: 20pt, weight: "bold")[#it.body]
  ]
  v(1cm)
}

#show heading.where(level: 2): it => {
  v(2.1em)
  text(size: 14pt, weight: "bold")[
    #if it.numbering != none [#counter(heading).display(it.numbering) #h(0.5em)]
    #it.body
  ]
  v(1.2em)
}

#show heading.where(level: 3): it => {
  v(1.4em)
  text(size: 12pt, weight: "bold")[
    #if it.numbering != none [#counter(heading).display(it.numbering) #h(0.5em)]
    #it.body
  ]
  v(0.8em)
}

// ── Cover page ──
#include "cover.typ"

// ── Title page ──
#include "title.typ"

// ── Front matter (roman page numbers) ──
#set page(numbering: "i")
#counter(page).update(1)

#include "abstract.typ"

// Table of Contents
= Contents
#outline(title: none, depth: 3, indent: auto)

#include "acknowledgements.typ"

// List of Tables
= List of Tables
#outline(title: none, target: figure.where(kind: table))

// List of Figures
= List of Figures
#outline(title: none, target: figure.where(kind: image))

// List of Code Listings
= List of Code Listings
#outline(title: none, target: figure.where(kind: raw))

// ── Main content (arabic page numbers) ──
#set page(numbering: "1")
#counter(page).update(1)
#set heading(numbering: "1.1.1")

#include "chapter1_introduction.typ"
#include "chapter2_frontend_design.typ"
#include "chapter3_core_participant_features.typ"
#include "chapter4_api_and_improvements.typ"
#include "chapter5_conclusion.typ"

// ── Bibliography ──
#pagebreak(weak: true)
#bibliography("bib.bib", title: "Bibliography", style: "ieee")
