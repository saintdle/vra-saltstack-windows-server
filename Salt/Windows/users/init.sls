{%- set RENAME_ADMIN = pillar.get('RENAME_ADMIN', 'localadmin') %}
rename_administrator:
  lgpo.set:
    - computer_policy:
        "Accounts: Rename administrator account": {{ RENAME_ADMIN }}

{% set DomainRole = salt['system.get_system_info']()['os_type'] %}
{% if DomainRole == 'Domain Controller' %}
notify_notMS-administrator_account_disable:
  test.nop:
    - name: 'This system is not a Windows Member Server'
{%- else %}
administrator_account_status_disable:
  lgpo.set:
    - computer_policy:
        "Accounts: Administrator account status": 'Disabled'
    - require:
      - rename_administrator
{% endif %}
