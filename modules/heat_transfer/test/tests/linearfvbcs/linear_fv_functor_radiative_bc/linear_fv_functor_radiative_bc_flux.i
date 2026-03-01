# Verification that SideLinearFVFluxBCIntegral returns zero for
# LinearFVFunctorRadiativeBC at thermal equilibrium (T_L = T_inf).
# When T_surface = T_inf the radiative flux q = sigma*eps*(T^4 - Tinf^4) = 0
# everywhere on the boundary.

T_L   = 500.0
T_inf = 500.0
eps   = 1.0
k     = 1.0

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 10
    xmin = 0
    xmax = 1
  []
[]

[Problem]
  linear_sys_names = 'heat_system'
[]

[Variables]
  [T]
    type = MooseLinearVariableFVReal
    solver_sys = 'heat_system'
    initial_condition = ${T_L}
  []
[]

[LinearFVKernels]
  [time]
    type = LinearFVTimeDerivative
    variable = T
  []
  [diffusion]
    type = LinearFVDiffusion
    variable = T
    diffusion_coeff = ${k}
  []
[]

[LinearFVBCs]
  [left]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = T
    boundary = 'left'
    functor = ${T_L}
  []
  [right]
    type = LinearFVFunctorRadiativeBC
    variable = T
    boundary = 'right'
    emissivity = ${eps}
    Tinfinity = ${T_inf}
    diffusion_coeff = ${k}
  []
[]

[Postprocessors]
  [flux_right]
    type = SideLinearFVFluxBCIntegral
    boundary = 'right'
    linear_fv_bcs = 'right'
    execute_on = TIMESTEP_END
  []
[]

[Executioner]
  type = Transient
  system_names = heat_system
  scheme = 'implicit-euler'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  dt = 1e6
  num_steps = 5
  l_tol = 1e-10
[]

[Outputs]
  csv = true
  execute_on = final
[]
