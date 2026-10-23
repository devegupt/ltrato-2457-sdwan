# Verify every site/router declared in data/sites_*.nac.yaml is actually onboarded to SD-WAN Manager,
# in sync, and attached to the device template declared in YAML.

*** Settings ***
Documentation    Verify SD-WAN edge device onboarding and config status
Resource         ../../sdwan_common.resource
Suite Setup      Login SDWAN Manager
Suite Teardown   Logout SDWAN Manager
Default Tags     sdwan    day1    config    site

*** Keywords ***
Get vEdge By Chassis
    [Arguments]   ${chassis}
    ${r}=   GET On Session   sdwan_manager   /dataservice/system/device/vedges
    ${matches}=   Evaluate   [d for d in $r.json()['data'] if d.get('chasisNumber') == '${chassis}']
    Length Should Be   ${matches}   1   msg=Expected exactly one vEdge with chassis ${chassis}
    RETURN   ${matches}[0]

*** Test Cases ***
{% for site in sdwan.sites %}
{% for router in site.routers %}
Verify {{ router.device_variables.system_hostname }} ({{ router.chassis_id }}) Is Onboarded
    ${device}=   Get vEdge By Chassis   {{ router.chassis_id }}
    Set Suite Variable   ${device}

Verify {{ router.device_variables.system_hostname }} Reachability And Sync Status
    Should Be Equal Value Json String   ${device}   $.reachability   reachable   msg=reachability
    Should Be Equal Value Json String   ${device}   $.configStatusMessage   In Sync   msg=configStatusMessage
    Should Be Equal Value Json String   ${device}   $.vedgeCertificateState   certinstalled   msg=vedgeCertificateState

Verify {{ router.device_variables.system_hostname }} Matches Declared YAML
    Should Be Equal Value Json String   ${device}   $.template   {{ router.device_template }}   msg=template
    Should Be Equal Value Json String   ${device}   $.['host-name']   {{ router.device_variables.system_hostname }}   msg=host-name
    Should Be Equal Value Json String   ${device}   $.['site-id']   {{ router.device_variables.site_id }}   msg=site-id
    Should Be Equal Value Json String   ${device}   $.['system-ip']   {{ router.device_variables.system_ip }}   msg=system-ip
{% endfor %}
{% endfor %}
