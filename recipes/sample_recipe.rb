# must library
%w(
  wget
  gcc
  gcc-c++
  curl-devel
  expat-devel
  openssl-devel
  zlib-devel
  perl-ExtUtils-MakeMaker
  readline-devel
  libyaml-devel
  sqlite-devel
  libffi-devel  
).each do |pkg|
  package "#{pkg}" do
    action :install
    not_if "rpm -q #{pkg}"
  end
end

DOWNLOAD_DIR = "/var/tmp"
GIT_INSTALL_DIR = "/usr/local"
RBENV_DIR = "/usr/local/rbenv"
RBENV_SCRIPT = "/etc/profile.d/rbenv.sh"
RUBY_VERSION = "2.3.0"


# git latast install
execute "Remove already installed git" do
  command "yum -y remove git"
  only_if "rpm -q git"
end

execute "Download git latest" do
  cwd "#{DOWNLOAD_DIR}"
  command "wget https://www.kernel.org/pub/software/scm/git/git-2.9.3.tar.gz"
  not_if "test -f #{DOWNLOAD_DIR}/git-2.9.3.tar.gz"
end

execute "Decompression git tar.gz" do
  cwd "#{DOWNLOAD_DIR}"
  command "tar zxvf git-2.9.3.tar.gz"
  not_if "test -d #{DOWNLOAD_DIR}/git-2.9.3"
end

execute "Make install git" do
  cwd "#{DOWNLOAD_DIR}/git-2.9.3"
  command "make prefix=#{GIT_INSTALL_DIR} all; make prefix=#{GIT_INSTALL_DIR} install"
  not_if "test -e #{GIT_INSTALL_DIR}/bin/git"
end

link "Set symbolic link installed git " do
  link "/usr/bin/git"
  to "#{GIT_INSTALL_DIR}/bin/git"
end

# rbenv install
git RBENV_DIR do
  repository "https://github.com/sstephenson/rbenv.git"
end

directory "#{RBENV_DIR}/plugins" do
  action :create
end

git "#{RBENV_DIR}/plugins/ruby-build" do
  repository "https://github.com/sstephenson/ruby-build.git"
end

remote_file RBENV_SCRIPT do
  action :create
  source "remote_files/rbenv.sh"
  owner "root"
  group "root"
  mode "644"
end

execute "install ruby" do
  command "source #{RBENV_SCRIPT}; rbenv install #{RUBY_VERSION}"
  not_if "source #{RBENV_SCRIPT}; rbenv versions | grep #{RUBY_VERSION}"
end

execute "set global ruby" do
  command "source #{RBENV_SCRIPT}; rbenv global #{RUBY_VERSION}; rbenv rehash"
  not_if "source #{RBENV_SCRIPT}; rbenv global | grep #{RUBY_VERSION}"
end

execute "gem install bundler" do
  command "source #{RBENV_SCRIPT}; gem install bundler --no-ri --no-rdoc; rbenv rehash"
  not_if "source #{RBENV_SCRIPT}; gem list | grep bundler"
end





