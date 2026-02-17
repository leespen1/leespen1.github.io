+++
title = "Spencer Lee"
tags = ["syntax", "code"]
commonmark_safe = false
+++

# About Me

~~~
<img src="/assets/FS21_Headshot_Cropped.jpg" alt="Picture of Me"
style="float: right; width: 180px; margin: 0 0 1em 1.5em; border-radius: 8px; padding: 0;">
~~~

I am a PhD student at Michigan State University, studying computational
mathematics. My main motivation is to develop numerical software for solving
cutting-edge scientific problems. My biggest project as a PhD student has been
devloping [QuantumGateDesign.jl](https://github.com/leespen1/QuantumGateDesign.jl),
an open-source Julia package that solves quantum optimal control problems (e.g.
shaping control pulses to implement quantum logic gates) quickly by using a
high-order Hermite method and a continuous control pulse model.

In general, my interests include applying numerical methods to problems in
science and industry, writing scientific software, making cool visualizations,
and good pedagogy. 

# Publications
- [High-Order Hermite Optimization: Fast and Exact Gradient Computation in Open-Loop Quantum Optimal Control using a Discrete Adjoint Approach](https://doi.org/10.48550/arXiv.2505.09857)

# Software
- [QuantumGateDesign.jl Tutorial - SIAM Annual Meeting 2025](https://github.com/leespen1/SIAMQuantumGateDesignTutorial)
- [QuantumGateDesign.jl](https://github.com/leespen1/QuantumGateDesign.jl)
- [My Github](https://github.com/leespen1)

# Blog Posts
{{blogposts}}

# Contact
- Email: leespen1@msu.edu
~~~
<blockquote id="quote-of-the-day"></blockquote>
<script>
var quotes = [
  {text: "Be it known that, waiving all argument, I take the good old fashioned ground that the whale is a fish.", author: "Herman Melville", source: "Moby Dick"},
  {text: "In mathematics you don't understand things. You just get used to them.", author: "John von Neumann"},
  {text: "An approximate answer to the right problem is worth a good deal more than an exact answer to an approximate problem.", author: "John Tukey"}
];
var today = new Date();
var dayOfYear = Math.floor((today - new Date(today.getFullYear(),0,0)) / 86400000);
var q = quotes[dayOfYear % quotes.length];
var el = document.getElementById("quote-of-the-day");
var src = q.source ? ", <i>" + q.source + "</i>" : "";
el.innerHTML = '<p>"' + q.text + '"</p><footer>— <cite>' + q.author + src + '</cite></footer>';
</script>
~~~


