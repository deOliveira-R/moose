# 1D diffusion problem used to verify SideLinearFVFluxBCIntegral.
# Left BC: Dirichlet T = 300
# Right BC: Neumann flux = 10.0
# The postprocessor integrates the Neumann BC over the right boundary.
# Expected result: 10.0 (functor value * face area = 10.0 * 1.0 in 1D).

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 2
    xmin = 0
    xmax = 1
  []
[]

[Problem]
  linear_sys_names = 'u_sys'
[]

[Variables]
  [T]
    type = MooseLinearVariableFVReal
    solver_sys = 'u_sys'
    initial_condition = 300
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
    diffusion_coeff = 1.0
  []
[]

[LinearFVBCs]
  [left]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = T
    boundary = 'left'
    functor = 300
  []
  [right]
    type = LinearFVAdvectionDiffusionFunctorNeumannBC
    variable = T
    boundary = 'right'
    functor = 10.0
    diffusion_coeff = 1.0
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
  system_names = u_sys
  scheme = 'implicit-euler'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  dt = 1e6
  num_steps = 1
  l_tol = 1e-10
[]

[Outputs]
  csv = true
  execute_on = final
[]
