global with sharing class ClassifyVictims {

    /**
     * Invocable action for Flows: accepts a flat list of Victim_DMO__dlm records,
     * groups by email, calculates max scores, and returns classifications.
     */
    @InvocableMethod(
        label='Classify Victims' description='Classify victims by booking and job anomaly scores'
    )
    global static List<VictimClassificationOutput> classifyVictims(
        List<Victim_DMO__dlm> victims
    ) {
        // 1) Group by email & compute max scores
        Map<String, ScorePair> emailToScores = new Map<String, ScorePair>();
        for (Victim_DMO__dlm v : victims) {
            if (!emailToScores.containsKey(v.KQ_Email__c)) {
                emailToScores.put(v.KQ_Email__c, new ScorePair());
            }
            ScorePair sp = emailToScores.get(v.KQ_Email__c);
            sp.maxBooking   = Math.max(sp.maxBooking,   v.BookingPatternScore_prediction__c);
            sp.maxAnomaly   = Math.max(sp.maxAnomaly,   v.JobAnomalyScore_prediction__c);
        }

        // 2) Build wrapper outputs for Flow
        List<VictimClassificationOutput> results = new List<VictimClassificationOutput>();
        for (String email : emailToScores.keySet()) {
            ScorePair sp = emailToScores.get(email);
            String risk;
            if (sp.maxBooking >= 75 || sp.maxAnomaly >= 75) {
                risk = 'High';
            } else if (sp.maxBooking >= 50 || sp.maxAnomaly >= 50) {
                risk = 'Medium';
            } else {
                risk = 'Low';
            }
            results.add(new VictimClassificationOutput(email, risk));
        }
        return results;
    }

    // Helper type for accumulating scores
    private class ScorePair {
        public Decimal maxBooking = 0;
        public Decimal maxAnomaly = 0;
    }

    // Flow‐compatible output wrapper — must be global for Apex-Defined
    global class VictimClassificationOutput {
        @InvocableVariable(label='Email'               description='Victim Email Address')
        public String email;

        @InvocableVariable(label='Risk Classification' description='High/Medium/Low')
        public String riskClassification;

        // No-arg constructor required
        public VictimClassificationOutput() {}

        // Convenience constructor
        public VictimClassificationOutput(String email, String risk) {
            this.email               = email;
            this.riskClassification  = risk;
        }
    }
}