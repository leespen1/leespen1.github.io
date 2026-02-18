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
I develop high-performance numerical methods and scientific software for quantum
optimal control and other cutting-edge scientific problems. I am a PhD candidate
in Computational Mathematics, Science, and Engineering at Michigan State
University, and I am the developer of the open-source Julia package
[QuantumGateDesign.jl](https://github.com/leespen1/QuantumGateDesign.jl), which
quickly solves quantum optimal control problems using a novel, high-order
numerical method based on Hermite interpolation.



# About Quantum Optimal Control

In quantum computing, algorithms are often written as *quantum circuits*. The
following quantum circuit takes two qubits in the ground state ($|0\rangle$) as
inputs, and outputs the maximally entangled Bell state 
$(|00\rangle + |11\rangle)/\sqrt{2}$.

~~~
<figure style="text-align:center;">
  <img src="/assets/img/BellStateCircuit.svg" width="400">
  <figcaption>Bell state preparation circuit.</figcaption>
</figure>
~~~

The squares and circles in the diagram are *quantum logic gates*, which are the
building blocks of quantum algorithms. The behavior of a quantum logic gate
is defined by how it affects the possible inputs of the gate.
For example, the Hadamard gate is defined by the following input-output maps in
the following table.

| Input State      | Output State                                 |
|------------------|----------------------------------------------|
| $\vert 0\rangle$ | $(\vert 0\rangle + \vert 1\rangle)/\sqrt{2}$ |
| $\vert 1\rangle$ | $(\vert 0\rangle - \vert 1\rangle)/\sqrt{2}$ |

Quantum circuit diagrams abstract away the physics and engineering work required
to implement a quantum algorithm using real hardware. It is assumed that we can do
operations like "apply a Hadamard gate to qubit 1", or "apply a CNOT gate on
qubits 1 and 2."

To implement a quantum logic gate on real quantum computing hardware, 
we control the amplitude of electromagnetic pulses to manipulate the quantum
system. This is called *pulse-shaping*, since we control the "shape" of the
pulse when plotting amplitude vs time.

For example, consider a qubit whose Hamiltonian is
\begin{equation*}
H(t) = \frac{\omega_0}{2}\sigma_z + c(t)\sigma_x,
\quad \omega_0 =
0.1 \textrm{GHz},
\end{equation*}
where $c(t)$ is the amplitude of an electromagnetic pulse which we control. \sidenote{sn:hadamard_example_hamiltonian}{In the computational basis, where $|0\rangle = \begin{bmatrix}1 \\ 0 \end{bmatrix}$ and $|1\rangle = \begin{bmatrix}0 \\ 1 \end{bmatrix}$, the matrix forms of the operators are  $\sigma_z \equiv \begin{bmatrix} 1 & 0 \\ 0 & -1 \end{bmatrix}, \quad \sigma_x \equiv \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}$.}
Using numerical simulation and optimization, I found that the following control
pulse implements a Hadamard gate very accurately.
~~~
<figure style="text-align:center;">
  <img src="/assets/img/hadamard_pulse_example.svg" style="width:100%; padding-left:0;">
  <figcaption>Control pulse implementing a Hadamard gate.</figcaption>
</figure>
~~~

We can also design multi-qubit gates, like a Controlled NOT
gate.\sidenote{sn:cnot_note}{This is represented by the dot and circle in the
same column in the Bell state preparation circuit diagram.}. For each qubit we
add, the size of the numerical representation of the system doubles, which
makes simulating the  system more computationally expensive. In addition,
depending on the Hamiltonian of a given quantum system, the system may have very
"fast" dynamics which are computationally expensive to simulate. Moreover, the
parameters of an individual quantum system tend to drift over time, so that the
control pulses must be recalibrated on a regular basis

My work focuses on novel methods to accelerate the simulation of the quantum
system (while still keeping some properties which are necessary for efficiently
optimizing the pulse shape) so that we can efficiently design and recalibrate
pulse shapes to implement accurate, multi-qubit gates.

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
