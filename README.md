# EEG-SMT Docker container

I have the [Olimex EEG-SMT](https://www.olimex.com/Products/EEG/OpenEEG/EEG-SMT/open-source-hardware), which is an affordable prefabricated realization of the open-hardware [OpenEEG project](http://openeeg.sourceforge.net/).

I wanted simple access to the raw data from Python when running on Linux. Getting all the parts running correctly requires some effort, so I decided to dockerize everything so that it would be easy to reproduce.

The NeuroServer daemon acts as a hub: the modeegdriver sends data from the EEG-SMT to it, and the plotting program receives the data from it, and stores screnshots in the `images` subdirectory.

## Quick start

Run

```bash
git clone https://github.com/maresb/eeg-smt-docker.git
cd eeg-smt-docker
echo "MY_UID=$(id -u)" > .env
echo "MY_GID=$(id -g)" >> .env
docker-compose up --abort-on-container-exit --force-recreate
```

When you are finished, to clean up the stopped containers and network, run

```bash
docker-compose down
```

to stop the NeuroServer daemon and EEG driver.

## Troubleshooting

In case of problems, check

```bash
MY_UID="$(id -u)" docker-compose logs -f
```

If you see a bunch of stuff like

```log
eeg-smt-modeegdriver-service-1  | P3 sync error:i=1,j=1,c=203.
eeg-smt-modeegdriver-service-1  | P3 sync error:i=0,j=2,c=188.
eeg-smt-modeegdriver-service-1  | P3 sync error:i=0,j=2,c=165.
eeg-smt-modeegdriver-service-1  | Serial packet sync error -- missed window.
eeg-smt-modeegdriver-service-1  | P3 sync error:i=0,j=1,c=140.
eeg-smt-modeegdriver-service-1  | P3 sync error:i=0,j=2,c=165.
eeg-smt-modeegdriver-service-1  | P3 sync error:i=0,j=1,c=141.
```

then run

```bash
MY_UID="$(id -u)" docker-compose down
```

and try again.

## License

Everything here is licensed under [GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html). NeuroServer is redistributed from [SourceForge](http://openeeg.sourceforge.net/neuroserver_doku/), mirrored on [GitHub](https://github.com/BCI-AR/NeuroServer), and is copyright the NeuroServer authors. The rest is copyright Ben Mares, 2022.
