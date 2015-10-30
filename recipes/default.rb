#
# Cookbook Name:: rvm
# Recipe:: default
#
# Copyright 2015, David Saenz Tagarro
#
# All rights reserved - Do Not Redistribute
#

user_name = node['rvm']['user']['name']
user_password = node['rvm']['user']['password']
home = "/home/#{user_name}"

package %w(gnupg curl)

ruby_block 'install_rvm' do
  block do
    cmd = Mixlib::ShellOut.new(
      'gpg --keyserver hkp://keys.gnupg.net ' \
      '--recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3',
      user: user_name, password: user_password, cwd: home)
    cmd.run_command
    cmd.error!

    cmd = Mixlib::ShellOut.new(
      '\curl -sSL https://get.rvm.io | bash -s stable',
      user: user_name, password: user_password, cwd: home)
    cmd.run_command
    cmd.error!
  end
  action :create
  notifies :run, 'execute[bootstrap_bashrc]', :immediately
end

execute 'bootstrap_bashrc' do
  command <<-EOH
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> .bashrc
  EOH
  user 'vagrant'
  cwd home
  notifies :create, 'file[lock_rvm]', :immediately
end

file 'lock_rvm' do
  path "#{home}/.lockrvm"
  name 'lock_rvm'
  user 'vagrant'
  action :nothing
end
