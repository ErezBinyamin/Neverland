# Play Empire Earth in docker using wine
- Makes use of [scottyhardy/docker-wine](https://github.com/scottyhardy/docker-wine)
- Follows some steps from EE2 linux tutorial from [EE2.eu](https://www.ee2.eu/linux/)
- Based on [this gist](https://gist.github.com/ErezBinyamin/6199e8fe1388c0521d6398e380641cdf)
- Maintained more actively on [GitHub](https://github.com/ErezBinyamin/Neverland/tree/main/ee2wine)

## How to use this container
1. Build using [Makefile](Makefile)
2. Enter container using `ee2wine` function defined in [ee2wine.sh](../ScriptWrappers/ee2wine.sh)
3. Complete post-install steps
4. _optionally_ use `docker commit` to save post-install steps to local image
5. Launch game using `wine`
