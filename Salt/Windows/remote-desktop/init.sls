# If statement to check the Minion targets grain reports the OS as Windows
{% if grains.os == 'Windows' %}

enable_service_rds:
  service.enabled:
    - name: TermService
  
start_service_rds:
  service.running:
    - name: TermService
    
reg_enable_rds_connections:
  reg.present:    
    - name: HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server
    - vname: fDenyTSConnections
    - vdata: 0
    - vtype: REG_DWORD
    
{% endif %}
