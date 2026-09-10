/**
 * HelpdeskKanbanController
 * Contrôleur pour afficher les cases dans un Kanban avec vue par queue
 */
public with sharing class HelpdeskKanbanController {

    /**
     * Récupère les queues auxquelles l'utilisateur appartient avec le nombre de cas non-fermés
     */
    @AuraEnabled(cacheable=true)
    public static List<QueueWithCaseCount> getQueuesWithCaseCount() {
        List<QueueWithCaseCount> result = new List<QueueWithCaseCount>();
        
        try {
            // Récupérer les queues auxquelles l'utilisateur appartient
            List<GroupMember> members = [
                SELECT GroupId, Group.Name, Group.Id
                FROM GroupMember
                WHERE UserOrGroupId = :UserInfo.getUserId()
                AND Group.Type = 'Queue'
                ORDER BY Group.Name
            ];
            
            Set<Id> queueIds = new Set<Id>();
            Map<Id, String> queueNames = new Map<Id, String>();
            
            for (GroupMember member : members) {
                if (!queueIds.contains(member.GroupId)) {
                    queueIds.add(member.GroupId);
                    queueNames.put(member.GroupId, member.Group.Name);
                }
            }
            
            // Compter les cases non-fermées par queue
            List<AggregateResult> caseCount = [
                SELECT QueueId, COUNT(Id) caseCount
                FROM Case
                WHERE QueueId IN :queueIds
                AND Status != 'Closed'
                GROUP BY QueueId
            ];
            
            Map<Id, Integer> caseCounts = new Map<Id, Integer>();
            for (AggregateResult ar : caseCount) {
                caseCounts.put((Id)ar.get('QueueId'), (Integer)ar.get('caseCount'));
            }
            
            // Construire la réponse
            for (Id queueId : queueIds) {
                QueueWithCaseCount qwcc = new QueueWithCaseCount();
                qwcc.queueId = queueId;
                qwcc.queueName = queueNames.get(queueId);
                qwcc.caseCount = caseCounts.get(queueId) != null ? caseCounts.get(queueId) : 0;
                result.add(qwcc);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Erreur lors de la récupération des queues: ' + e.getMessage());
        }
        
        return result;
    }

    /**
     * Récupère les statuts Kanban disponibles depuis le picklist Kanban_Status__c sur Case
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getKanbanStatuses() {
        List<String> statuses = new List<String>();
        
        try {
            Schema.DescribeFieldResult fieldResult = Case.Kanban_Status__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistValues) {
                if (entry.isActive()) {
                    statuses.add(entry.getLabel());
                }
            }
            
        } catch (Exception e) {
            System.debug('Error getting Kanban statuses: ' + e.getMessage());
        }
        
        return statuses;
    }

    /**
     * Récupère les cases pour le Kanban : queue sélectionnée + cas personnels de l'utilisateur
     */
    @AuraEnabled
    public static List<CaseWrapper> getCasesForKanban(Id queueId, Id userId) {
        List<CaseWrapper> result = new List<CaseWrapper>();
        
        try {
            // Récupérer les cases de la queue (max 200)
            List<Case> queueCases = [
                SELECT Id, CaseNumber, Subject, Status, Priority, 
                       Kanban_Status__c, CreatedDate, Account.Name
                FROM Case
                WHERE QueueId = :queueId
                AND Status != 'Closed'
                LIMIT 200
            ];
            
            // Récupérer les cases personnelles (max 100)
            List<Case> userCases = [
                SELECT Id, CaseNumber, Subject, Status, Priority, 
                       Kanban_Status__c, CreatedDate, Account.Name
                FROM Case
                WHERE OwnerId = :userId
                AND Status != 'Closed'
                LIMIT 100
            ];
            
            // Fusionner
            List<Case> allCases = new List<Case>();
            allCases.addAll(queueCases);
            allCases.addAll(userCases);
            
            // Convertir en wrapper
            for (Case caseItem : allCases) {
                result.add(new CaseWrapper(caseItem));
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Erreur au chargement des cas: ' + e.getMessage());
        }
        
        return result;
    }

    /**
     * Récupère les cases pour l'utilisateur connecté
     */
    @AuraEnabled
    public static List<CaseWrapper> getUserQueues() {
        List<CaseWrapper> result = new List<CaseWrapper>();
        
        try {
            List<Case> userCases = [
                SELECT Id, CaseNumber, Subject, Status, Priority, 
                       Kanban_Status__c, CreatedDate, Account.Name
                FROM Case
                WHERE OwnerId = :UserInfo.getUserId()
                AND Status != 'Closed'
                LIMIT 100
            ];
            
            for (Case caseItem : userCases) {
                result.add(new CaseWrapper(caseItem));
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Erreur: ' + e.getMessage());
        }
        
        return result;
    }

    /**
     * Met à jour le statut Kanban d'une case
     */
    @AuraEnabled
    public static void updateCaseKanbanStatus(Id caseId, String newStatus) {
        try {
            Case caseToUpdate = new Case(Id = caseId);
            caseToUpdate.Kanban_Status__c = newStatus;
            update caseToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException('Erreur lors de la mise à jour: ' + e.getMessage());
        }
    }

    /**
     * Classe wrapper pour les cases
     */
    public class CaseWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        
        @AuraEnabled
        public String CaseNumber { get; set; }
        
        @AuraEnabled
        public String Subject { get; set; }
        
        @AuraEnabled
        public String Status { get; set; }
        
        @AuraEnabled
        public String Priority { get; set; }
        
        @AuraEnabled
        public String Kanban_Status__c { get; set; }
        
        @AuraEnabled
        public String CreatedDate { get; set; }
        
        @AuraEnabled
        public AccountWrapper Account { get; set; }
        
        public CaseWrapper(Case caseItem) {
            this.Id = caseItem.Id;
            this.CaseNumber = caseItem.CaseNumber;
            this.Subject = caseItem.Subject;
            this.Status = caseItem.Status;
            this.Priority = caseItem.Priority;
            this.Kanban_Status__c = caseItem.Kanban_Status__c;
            this.CreatedDate = caseItem.CreatedDate.format();
            this.Account = new AccountWrapper(caseItem.Account);
        }
    }
    
    public class AccountWrapper {
        @AuraEnabled
        public String Name { get; set; }
        
        public AccountWrapper(Account acc) {
            this.Name = acc != null ? acc.Name : 'N/A';
        }
    }
    
    public class QueueWithCaseCount {
        @AuraEnabled
        public Id queueId { get; set; }
        
        @AuraEnabled
        public String queueName { get; set; }
        
        @AuraEnabled
        public Integer caseCount { get; set; }
    }
}
