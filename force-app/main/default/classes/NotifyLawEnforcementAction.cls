public with sharing class NotifyLawEnforcementAction{
    @InvocableMethod
    public static List<Response> invoke(List<Request> inputs) {
        Request input = inputs[0];
        if (input == null || String.isBlank(input.Name)) {
            System.debug('Victim Name is required.');
        }
        // 1. Fetch DMO
        Victim_DMO__dlm dmo = 
            [SELECT FullName__c, DestinationCountry__c, OriginCountry__c
             FROM Victim_DMO__dlm
             WHERE FullName__c = :input.Name
             LIMIT 1];
        //[SELECT Id__c
        //FROM JobPostings_trainingData__dlm];
        //WHERE Com_email__c = 'rajesh.sharma12@example.com'];
        
        
        // 2. Find contacts for both countries
        List<String> countries = new List<String>{dmo.DestinationCountry__c, dmo.OriginCountry__c};
            //Custom metadata
            List<Agency_Detail__mdt> AgencyCustomMetadata = [SELECT Country__c, Email__c 
                                                             FROM Agency_Detail__mdt 
                                                             WHERE Country__c IN :countries];
        System.debug(AgencyCustomMetadata);
        Map<String, String> countryToEmailMap = new Map<String, String>();
        for (Agency_Detail__mdt AgencyMD : AgencyCustomMetadata) {
            countryToEmailMap.put(AgencyMD.Country__c, AgencyMD.Email__c);
        }
		System.debug(countryToEmailMap);
        //Map<String, String> countryToEmailMap = LawEnforcementDirectoryService.getEmailsByCountries(countries);
        // 3. Compose message
        String message = 
            'Dear Team,\n\n' +
            '🚨 Urgent Alert\n\n' +
            'Victim Name: ' + dmo.FullName__c + '\n' +
            'Risk Level: High\n\n' +
            'Details:\n' +
            '- Destination Country: ' + dmo.DestinationCountry__c + '\n' +
            '- Origin Country: ' + dmo.OriginCountry__c + '\n\n' +
			'- Case Description: ' + input.Summary + '\n\n' +
            'Please take immediate action as necessary.\n\n' +
            'Best regards,\n' +
            '[Your Name or Department]';
        
        
        // 4. Send emails
        for (String email : countryToEmailMap.values()) {
			System.debug(email);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{email});
            mail.setSubject('🚨 Human Trafficking Alert – ' + dmo.FullName__c);
            mail.setPlainTextBody(message);
            Messaging.sendEmail(new List<Messaging.Email>{mail});
        }
        Response output = new Response();
        output.result = '✅ Law enforcement notified for ' + dmo.DestinationCountry__c + ' and ' + dmo.OriginCountry__c + '.';
        //return output;
        return new List<Response>{ output };
            }
    public class Request {
        @InvocableVariable//(label='Victim ID', description='Unique external ID of the victim', required=true)
        public String Name;
        public String Summary;
    }
    public class Response {
        @InvocableVariable//(label='Result', description='Notification status')
        public String Result;
    }
}