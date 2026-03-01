# SideLinearFVFluxBCIntegral

Computes the side integral of different linear finite volume advection-diffusion boundary
conditions. Let $F(u)$ denote a flux on the boundary given by a boundary condition. This
postprocessor provides the following expression:

\begin{equation}
\int_S \sum_i^{N_{bc}} F_i(u) \, dS,
\end{equation}

where $N_{bc}$ is the number of specified boundary conditions and $S$ denotes the boundary
surface. The sign convention is positive for flux leaving the domain.

!alert warning
The current implementation only supports objects that inherit from
`LinearFVAdvectionDiffusionBC` and override `computeFlux()`. Using it with a boundary
condition that does not implement `computeFlux()` will result in a run-time error.

## Example Input Syntax

!listing test/tests/postprocessors/side_linear_fv_flux_bc_integral/side_linear_fv_flux_bc_integral.i block=Postprocessors

!syntax parameters /Postprocessors/SideLinearFVFluxBCIntegral

!syntax inputs /Postprocessors/SideLinearFVFluxBCIntegral

!syntax children /Postprocessors/SideLinearFVFluxBCIntegral
