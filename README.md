# MWCCP Heuristics — TU Wien | Heuristic Optimization Techniques (WS 2024)

This repository contains the first part of a larger assignment for the course **Heuristic Optimization Techniques** at **TU Wien**, **Winter Semester 2024**.

## Problem: Minimum Weighted Crossing with Constraints Problem (MWCCP)

The MWCCP is a combinatorial optimization problem involving a bipartite graph where each edge has an individual weight. The objective is to find an ordering of the nodes in one layer that minimizes the total cost caused by edge crossings, where the cost of a crossing between two edges is the sum of their individual weights. If two edges do not cross, no cost is incurred. The problem is subject to constraints such as node ordering restrictions.
The problem is NP-hard, making it well-suited for heuristic and metaheuristic approaches.

## Objective of this assignment

The goal of this part of the project is to design, implement, and evaluate a range of **heuristic and metaheuristic methods** introduced in the course, as applied to MWCCP.

### Implemented techniques

- **Construction Heuristics**: Generate initial feasible solutions with varying strategies.
- **Simulated Annealing (SA)**: Improve solutions via probabilistic local search.
- **GRASP** (Greedy Randomized Adaptive Search Procedure): Iterative construction (randomized construction heuristic) + improvement (local search).
- **VND** (Variable Neighborhood Descent): Explores multiple neighborhood structures for local optima.

These approaches form a solid foundation of the elementary techniques covered in the lecture.
