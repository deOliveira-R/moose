//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SideLinearFVFluxBCIntegral.h"
#include "LinearFVAdvectionDiffusionBC.h"

registerMooseObject("MooseApp", SideLinearFVFluxBCIntegral);

InputParameters
SideLinearFVFluxBCIntegral::validParams()
{
  InputParameters params = SideIntegralPostprocessor::validParams();
  params.addRequiredParam<std::vector<std::string>>(
      "linear_fv_bcs",
      "List of boundary conditions whose contribution we want to integrate.");
  params.addClassDescription(
      "Computes the side integral of different linear finite volume advection-diffusion "
      "boundary conditions.");
  return params;
}

SideLinearFVFluxBCIntegral::SideLinearFVFluxBCIntegral(const InputParameters & parameters)
  : SideIntegralPostprocessor(parameters),
    _bc_names(getParam<std::vector<std::string>>("linear_fv_bcs"))
{
  _qp_integration = false;
}

void
SideLinearFVFluxBCIntegral::initialSetup()
{
  SideIntegralPostprocessor::initialSetup();

  // BCs are constructed after the postprocessors so we shall do this
  // in the initialization step.
  auto base_query = _fe_problem.theWarehouse()
                        .query()
                        .condition<AttribSystem>("LinearFVBoundaryCondition")
                        .condition<AttribThread>(_tid);

  // Fetch the mentioned boundary conditions
  _bc_objects.clear();
  for (const auto & name : _bc_names)
  {
    std::vector<LinearFVAdvectionDiffusionBC *> bcs;
    base_query.condition<AttribName>(name).queryInto(bcs);
    if (bcs.size() == 0)
      paramError("linear_fv_bcs",
                 "The given LinearFVAdvectionDiffusionBC with name '",
                 name,
                 "' was not found! This can be due to the boundary condition not existing in the "
                 "'LinearFVBCs' block or the boundary condition not inheriting from "
                 "LinearFVAdvectionDiffusionBC.");

    // We expect the code to error at an earlier stage if there are more than one
    // BCs with the same name
    _bc_objects.push_back(bcs[0]);
  }

  // Check if the boundary restriction of the objects is the same.
  for (const auto bc_ptr : _bc_objects)
    // Comparing ordered sets
    if (this->boundaryIDs() != bc_ptr->boundaryIDs())
      paramError("linear_fv_bcs",
                 "The given boundary condition with name ",
                 bc_ptr->name(),
                 " does not have the same boundary restriction as this postprocessor!");
}

Real
SideLinearFVFluxBCIntegral::computeFaceInfoIntegral(const FaceInfo * const fi)
{
  Real flux_value = 0.0;
  for (auto bc_ptr : _bc_objects)
  {
    bc_ptr->setupFaceData(
        fi,
        fi->faceType(std::make_pair(bc_ptr->variable().number(), bc_ptr->variable().sys().number())));
    flux_value += bc_ptr->computeFlux();
  }
  return flux_value;
}

Real
SideLinearFVFluxBCIntegral::computeQpIntegral()
{
  mooseError("We should never call this function!");
}
