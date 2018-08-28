# Download dependencies tool
if [ -d dependencies ];
then
  cd dependencies
  git pull
  cd ..
else
  git clone ssh://stash.bitvis.no/bv_tools/dependencies.git
fi

# Run dependencies tool
# Clone non-existant repos
python dependencies/src/dependencies.py clone ssh://stash.bitvis.no/bv_dip/bitvis_irqc.git

# Create symbolic link to Vagrant file
# Method of doing this for the Windows slave is:
# mklink Vagrantfile bitvis_util\Vagrantfile
if [ ! -e Vagrantfile ];
then
  ln -s bitvis_irqc/Vagrantfile .
fi

# Start vagrant box and perform simulation
vagrant up

vagrant ssh << END
set -x
cd /vagrant/
cd bitvis_irqc/sim/
python internal_run.py --clean --no-color --xunit-xml xunit-report.xml
END

