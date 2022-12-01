*** Settings ***
Documentation     This is a test suite for the Doctor Who Postgres Database and API
Library           RequestsLibrary
Library           JSONLibrary
Library           Collections

*** Variables ***
${base_url}       http://localhost:8080/doctor
${1stdoctor_id}   f747d61b-6801-4997-a723-a6fad277f5fc
${9thdoctor_id}   96676c76-5ff2-450a-af41-f0b41209f4bd


*** Test Cases ***
Do a GET request for the 9th Doctor and validate the response code and response body
    [documentation]     This test case verifies that the GET request response code should be 200,
    ...                and the response body should be the 9th Doctor

    Create Session  mysession  ${base_url}
    ${response}=  Get On Session  mysession  /${9thdoctor_id}
    #Check response status code
    Status Should Be  200  ${response}

    #Check actor name from response body
    ${actor_name}=  Get Value from Json  ${response.json()}  actor
    #The above line provides the information as a list, so we need to get the first element
    ${actorFromList}=  Get From List  ${actor_name}  0
    Should be equal  ${actorFromList}  Christopher Eccleston

Do a POST request with a new Doctor and validate the response code and response body

    [documentation]     This test case verifies that the POST request response code should be 200,
    ...                and the response body should be the new Doctor

    Create Session  mysession  ${base_url}
    &{body}=  Create Dictionary  number=17th  actor=Maisie Stewart  startYear=2028  endYear=2031
    ${response}=  Post On Session  mysession  /  json=${body}
    #Check response status code
    Status Should Be  200  ${response}

    #Check actor name from response body
    ${actor_name}=  Get Value from Json  ${response.json()}  actor
    ${actorFromList}=  Get From List  ${actor_name}  0
    Should be equal  ${actorFromList}  Maisie Stewart

Do a PUT request to update the end year of the 9th Doctor and validate the response code and response body

        [documentation]     This test case verifies that the PUT request response code should be 200,
        ...                and the response body should contain the end year 2006 before the PUT request and 2005 afterwards

        Create Session  mysession  ${base_url}
        ${response}=  Get On Session  mysession  /${9thdoctor_id}
        #Check response status code
        Status Should Be  200  ${response}

        #Check actor name from response body
        ${endYear}=  Get Value from Json  ${response.json()}  endYear
        #The above line provides the information as a list, so we need to get the first element
        ${endYearFromList}=  Get From List  ${endYear}  0
        ${endYearInt}=  Convert To Integer  2006
        Should be equal  ${endYearFromList}  ${endYearInt}

        &{body}=  Create Dictionary  number=9th  actor=Christopher Eccleston  startYear=2005  endYear=2005
        ${response}=  Post On Session  mysession  /  json=${body}
        #Check response status code
        Status Should Be  200  ${response}

        #Check actor name from response body
         ${endYear}=  Get Value from Json  ${response.json()}  endYear
         #The above line provides the information as a list, so we need to get the first element
         ${endYearFromList}=  Get From List  ${endYear}  0
         ${endYearInt}=  Convert To Integer  2005
         Should be equal  ${endYearFromList}   ${endYearInt}

Do a DELETE request to delete the 1st Doctor and validate the response code and there being no entry on the database

        [documentation]     This test case verifies that the DELETE request response code should be 200,
        ...                and the database contains no entry for number "1st"
        [tags]  delete
        Create Session  mysession  ${base_url}
        ${response}=  Delete On Session  mysession  /${1stdoctor_id}
        Status Should Be  200  ${response}

        #Check for 1st Doctor on the database
        Create Session  mysession  ${base_url}
        ${response}=  Get On Session  mysession  /${1stdoctor_id}
        #Check response status code
        log to console  ${response.status_code}
        Status Should Be  500  ${response}

*** Keywords ***

