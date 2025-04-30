public with sharing class GetAllVictimProfile {

    @InvocableMethod
    public static List<Response> getVictimDetails(List<Request> inputs) {
        List<Response> responses = new List<Response>();

        List<String> fieldNames = new List<String>{
            'Age__c',
            'ApplicantId__c',
            'ApplicationDate__c',
            'ApplicationId__c',
            'BookingId__c',
            'BookingPatternScore_prediction__c',
            'BookingSource__c',
            'CheckInTime__c',
            'CheckOutTime__c',
            'CustomerId__c',
            'DataSourceObject__c',
            'DataSource__c',
            'DestinationCountry__c',
            'FullName__c',
            'Gender__c',
            'HotelCountry__c',
            'HotelId__c',
            'HotelRiskScore__c',
            'InternalOrganization__c',
            'JobAnomalyScore_prediction__c',
            'JobPostingId__c',
            'Job_ApplicantId__c',
            'Job_CompanyName__c',
            'Job_EmployerRating__c',
            'Job_JobDescription__c',
            'Job_JobLocationCountry__c',
            'Job_JobPostingId__c',
            'Job_JobSearchPlatforms__c',
            'Job_JobTitle__c',
            'Job_RecruiterVerified__c',
            'Job_ReportedIncidentsCount__c',
            'Job_VisaSponsorship__c',
            'KQ_Email__c',
            'NativeCountry__c',
            'OriginCountry__c',
            'PaymentType__c',
            'PhoneNumber__c',
            'PlatformApplied__c',
            'Travel_BookingDate__c',
            'TravellingDate__c',
            'cdp_sys_SourceVersion__c'
        };

        for (Request input : inputs) {
            Response output = new Response();

            if (String.isBlank(input.inputPrompt)) {
                output.Prompt = '{"error":"Input prompt is required."}';
                responses.add(output);
                continue;
            }

            String userInput = String.escapeSingleQuotes(input.inputPrompt.trim());

            String sql = 
                'SELECT ' + String.join(fieldNames, ', ') +
                ' FROM Victim_DMO__dlm' +
                ' WHERE KQ_Email__c = \'' + userInput + '\'' +
                '    OR FullName__c = \'' + userInput + '\'';

            ConnectApi.CdpQueryInput cdpInput = new ConnectApi.CdpQueryInput();
            cdpInput.sql = sql;
            ConnectApi.CdpQueryOutputV2 cdpOutput = ConnectApi.CdpQuery.queryAnsiSqlV2(cdpInput);

            List<Map<String, Object>> records = new List<Map<String, Object>>();

            if (cdpOutput.data != null) {
                for (ConnectApi.CdpQueryV2Row row : cdpOutput.data) {
                    Map<String, Object> rec = new Map<String, Object>();
                    for (Integer i = 0; i < fieldNames.size(); i++) {
                        rec.put(fieldNames[i], row.rowData[i]);
                    }
                    records.add(rec);
                }
            }

            output.Prompt = JSON.serializePretty(records);
            responses.add(output);
        }

        return responses;
    }

    public class Request {
        @InvocableVariable
        public String inputPrompt;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}