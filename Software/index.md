+++
title = "Software — Spencer Lee | Open-Source Scientific Computing"
page_title = "Software"
description = "Open-source scientific software by Spencer Lee, including QuantumGateDesign.jl — a Julia package for quantum optimal control and gate design optimization."
tags = ["software", "Julia", "quantum"]
+++

You can find all of my projects on [my GitHub](https://github.com/leespen1).

## QuantumGateDesign.jl

[QuantumGateDesign.jl](https://github.com/leespen1/QuantumGateDesign.jl) is an
open-source Julia package which quickly solves quantum optimal control problems
using a novel, high-order numerical method based on Hermite interpolation. You
can read about the method in our
[publication in Journal of Computational Physics](https://doi.org/10.1016/j.jcp.2026.114697)
(or in the
[arXiv preprint](https://arxiv.org/abs/2505.09857)).

I presented a
[hands-on tutorial](https://github.com/leespen1/SIAMQuantumGateDesignTutorial/blob/main/SIAM_Tutorial.ipynb)
on QuantumGateDesign.jl at the
[SIAM Annual Meeting 2025](https://www.siam.org/conferences-events/siam-conferences/an25/),
which walks through setting up and solving quantum optimal control problems
using the package.

## Subtitle Player

[Subtitle Player](https://spencerlee.net/subtitle-player/) is a small web app I
made for reading subtitles on your phone while a movie plays on the TV. It runs
entirely in your mobile or desktop browser with no advertisments, and it's 100% free and
open-source! 

I made this so I could watch movies on a TV while in another country that
doesn't have English subtitles on their streaming platforms. There are many
apps for overlaying subtitles onto a video on your computer or phone, but
surprisingly I couldn't find a single one that handles *only subtitles.*

It turns out that subtitle files are incredibly simple plaintext (*as they
should be!*), so it was very simple to make a subtitle player using a small
amount of HTML/JavaScript.

The [source code is on GitHub](https://github.com/leespen1/subtitle-player).
