# This is a fairly generic Salt state which can be repurposed to install agents or applications on Windows minions

# Explanation of Variables
# 
# AGENT - Name of the agent as it appears in the Windows "Apps and Features". It will be used
#         to test if the agent is already installed
#
# FILE_TARGET - Location where the agent installer file will be copied to the minion
#
# FILE_SOURCE - Source for the installer file. This can be HTTPS / FTP / S3 / Salt filesystem / etc. 
#               Example: 'salt://' indicates the file is on the SaltStack Config Appliance.
#
# INSTALL_COMMAND - Switches and options required by the Windows package for installation
 
# Test if the target minion is running Windows before proceeding
{% if grains.os == 'Windows' %}

# Set variables using the Jinja templating language
# For more information:
# https://docs.saltproject.io/en/latest/topics/jinja/index.html
{% set AGENT = "Notepad" %}
{% set FILE_TARGET = 'C:\store\\npp.exe' %}
{% set FILE_SOURCE = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.4/npp.8.4.4.Installer.x64.exe" %}
{% set INSTALL_COMMAND = "/S" %}

# Test if the agent is already installed by listing the applications and comparing the output to the
# AGENT variable
# For more information on test states:
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.test.html
{% if AGENT | substring_in_list(salt['pkg.list_pkgs']('versions_as_list=True')) %}
agent_present:
  test.nop:
    - name: {{ AGENT }} is already installed.
    {% set AGENT_ALREADY_INSTALLED = 'Yes' %}
{% else %}
agent_absent:
  test.nop:
    - name: {{ AGENT }} is not present. Installing now.
    {% set AGENT_ALREADY_INSTALLED = 'No' %}
{% endif %}

{% if AGENT_ALREADY_INSTALLED == 'No' %}
# More information on file.managed:
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.file.html#salt.states.file.managed
agent_copy:
  file.managed:
     - name: {{ FILE_TARGET }}
     - source: {{ FILE_SOURCE }}
     - skip_verify: True

# More information on cmd.run:
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.cmd.html
agent_install:
  cmd.run:
    - name: {{ FILE_TARGET }} {{ INSTALL_COMMAND }}

# More information on file.absent:
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.file.html#salt.states.file.absent
agent_installer_cleanup:
  file.absent:
    - name: {{ FILE_TARGET }}

{% endif %}

{% endif %}
