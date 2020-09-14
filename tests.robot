*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    XML

*** Variables ***
${base_url}    https://www.openstreetmap.org
${api}    api

*** Test Cases ***
Get_api_versions
    # https://www.openstreetmap.org/api/versions
    Create Session    openstreetmap    ${base_url}
    ${response}=    Get Request    openstreetmap    /${api}/versions

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200

    ${response_content}=    Convert To String    ${response.content}
    Should Contain    ${response_content}    0.6

    ${content_type}=    Get from Dictionary    ${response.headers}    Content-Type
    Should Be Equal    ${content_type}    application/xml; charset=utf-8

Get_api_map_request
    # https://www.openstreetmap.org/api/0.6/map?bbox=0.18,52.15,0.19,52.16
    Create Session    openstreetmap    ${base_url}
    ${response}=    Get Request    openstreetmap    /${api}/0.6/map?bbox=13.05,52.5,13.08,52.52

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200

    ${response_content}=    Convert To String    ${response.content}
    Should Contain    ${response_content}    Heinz Sielmann Stiftung

Get_api_map_request_bad
    # https://www.openstreetmap.org/api/0.6/map?bbox=13,52.42,13.2,52.55
    Create Session    openstreetmap    ${base_url}
    ${response}=    Get Request    openstreetmap    /${api}/0.6/map?bbox=13,52.42,13.2,52.55

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    400

    ${response_content}=    Convert To String    ${response.content}
    Should Contain    ${response_content}    You requested too many nodes (limit is 50000)

Get_api_map_request_changeset
    # https://www.openstreetmap.org/api/0.6/changeset/613335
    Create Session    openstreetmap    ${base_url}
    ${response}=    Get Request    openstreetmap    /${api}/0.6/changeset/613335

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200

    ${response_content}=    Convert To String    ${response.content}
    ${elem}=    Get Element    ${response.content}    .//changeset
    Element Attribute Should Be    ${elem}    id    613335

Put_api_map_request_changeset
    # https://www.openstreetmap.org/api/0.6/changeset/613335
    Create Session    openstreetmap    ${base_url}
    ${body}=    Create Dictionary    created_at="2008-10-27T23:53:30Z" closed_at="2008-10-28T00:59:40Z" open="false" user="markcoley" uid="27598" min_lat="52.1404630" min_lon="0.1699742" max_lat="52.1594668" max_lon="0.2015324" comments_count="0" changes_count="281"
    ${header}=    Create Dictionary    Content-Type=application/xml;ch arset=utf-8
    ${response}=    Put Request    openstreetmap    /${api}/0.6/changeset/613335    data=${body}    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    401

    ${response_body}=    Convert To String    ${response.content}
    Should Contain    ${response_body}    Couldn't authenticate you

Put_api_map_request_changeset_close
    # https://www.openstreetmap.org/api/0.6/changeset/613335/close
    Create Session    openstreetmap    ${base_url}
    ${header}=    Create Dictionary    Content-Type=application/xml;ch arset=utf-8
    ${response}=    Put Request    openstreetmap    /${api}/0.6/changeset/613335/close    headers=${header}

    Log To Console    ${response.status_code}
    Log To Console    ${response.content}

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    401

    ${response_body}=    Convert To String    ${response.content}
    Should Contain    ${response_body}    Couldn't authenticate you

Get_api_map_request_changeset_download
    # https://www.openstreetmap.org/api/0.6/changeset/613335/download
    Create Session    openstreetmap    ${base_url}
    ${response}=    Get Request    openstreetmap    /${api}/0.6/changeset/613335/download

    #VALIDATE
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal    ${status_code}    200

    ${content_type}=    Get From Dictionary    ${response.headers}    Content-Type
    Should Be Equal    ${content_type}    application/xml; charset=utf-8

    ${changeset_count}=    Get Element Count    ${response.content}    .//node
    
    ${xml_list}=    Create List
    FOR    ${item}    IN RANGE    1    ${changeset_count}
        ${elem}=    Get Element   ${response.content}    .//modify[${item}]/*
        ${elem_attr}=    Get Element Attribute    ${elem}    timestamp
        Append To List    ${xml_list}    ${elem_attr}
    END
    ${primary_list}=    Copy List    ${xml_list}
    Sort List    ${xml_list}
    Lists Should Be Equal    ${primary_list}    ${xml_list}
