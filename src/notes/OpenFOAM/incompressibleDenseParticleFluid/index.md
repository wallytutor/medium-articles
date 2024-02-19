In OpenFOAM v11 solver module `incompressibleDenseParticleFluid` provides approaches for setting up a transient flow interacting with particles.

In this directory we discuss and assembly cases built using this solver to handle incompressible isothermal flows with fluid-particle interactions, including cases with dense packing of particles, such as packed beds or initialization of fluidized beds. 

The most complex file to set is `constant/cloudProperties`, as described [here](../Dictionaries/cloudProperties).

## Tutorial cases

- Goldschmidt
- GoldschmidtMPPIC
- column
- cyclone
- injectionChannel
## Boundary fields

Boundary fields in general are almost the same as any case in *pure fluid* simulations but transported quantities must be named by appending the name of the continuous phase specified in  `constant/physicalProperties` as `continuousPhaseName <phase>`. To make it simple let's call this phase `air` in what follows. Notice that pressure file name remains unchanged since it is not really *transported* as you don't have an equation in the form of Reynolds transport theorem for it.

That said, we have things as `k.air` and `U.air`.  The particularity here is that you must provide `phi` for all hydrodynamic solution variables (such as `k.air`, `U.air`) in outlets, what is implicit in single phase flow models. That means that an outlet for velocity should include something as

```C
outlet
{
	type            pressureInletOutletVelocity;
	phi             phi.air;
	inletValue      uniform (0 0 0);
	value           uniform (0 0 0);
}
```

## Problems found

- When working with non-constant particle size distribution (tested with `tabulatedDensity`) and `uniformParcelSize nParticle`, if `nParticle` is not `1` no particle mass inlet was possible. Probably the implementation of how to inject multiple particles per parcel is not implemented in this case (with sampling). Update: after some investigation and variants it would not work even with one particle per parcel. It seems related to the threshold of particle volume fraction per cell (set by `alphaMin` - to be confirmed) since for coarser meshes the it stopped injecting particles.

## List of samples

The lists below are provided in a relative order of complexity of model setup (options, post-processing, etc). That might be not the case with respect to the physics involved.
### Gas-particle flows

- [sedimentationBox](sedimentationBox): particles drop-off in a steady closed box.
- [injectionChannel](injectionChannel): particles injection in a channel with outlet flow rate (fan).
- [horizontalMixer](horizontalMixer): a simple mixer for testing several particle models.
- [dustCollector](dustCollector): study case of the role of deflectors over particle flows.

### Liquid-particle flows

- *Upcoming...*

