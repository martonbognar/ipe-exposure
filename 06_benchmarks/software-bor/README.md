# Software brown-out reset

These projects repeatedly trigger a brown-out reset on the board, sending a GPIO signal on each reset, which can be timed by the [`../timer`](../timer) project.
For the concrete I/O pin used, see the `main.c` file of each project.
