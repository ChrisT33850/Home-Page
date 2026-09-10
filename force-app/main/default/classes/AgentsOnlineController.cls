/**
 * AgentsOnlineController
 * Contrôleur pour afficher les agents en ligne et leurs statuts Omnichannel
 */
public with sharing class AgentsOnlineController {

    /**
     * Récupère les queues avec leurs membres
     */
    @AuraEnabled(cacheable=true)
    public static List<QueueWithMembers> getQueuesWithMembers() {
        List<QueueWithMembers> result = new List<QueueWithMembers>();
        
        try {
            // Récupérer les queues auxquelles l'utilisateur appartient
            List<GroupMember> members = [
                SELECT GroupId, Group.Name, Group.Id, 
                       UserOrGroupId
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
            
            // Pour chaque queue, récupérer les membres
            List<GroupMember> queueMembers = [
                SELECT GroupId, UserOrGroupId, User.Id, User.Name, 
                       User.SmallPhotoUrl, User.FirstName
                FROM GroupMember
                WHERE GroupId IN :queueIds
                AND User.IsActive = true
                ORDER BY User.Name
            ];
            
            Map<Id, List<Agent>> queueAgents = new Map<Id, List<Agent>>();
            
            for (GroupMember member : queueMembers) {
                if (!queueAgents.containsKey(member.GroupId)) {
                    queueAgents.put(member.GroupId, new List<Agent>());
                }
                
                Agent agent = new Agent();
                agent.userId = member.UserOrGroupId;
                agent.name = member.User.Name;
                agent.firstName = member.User.FirstName;
                agent.photoUrl = member.User.SmallPhotoUrl;
                agent.initials = member.User.FirstName.substring(0, 1).toUpperCase();
                
                queueAgents.get(member.GroupId).add(agent);
            }
            
            // Construire la réponse
            for (Id queueId : queueIds) {
                QueueWithMembers qwm = new QueueWithMembers();
                qwm.queueId = queueId;
                qwm.queueName = queueNames.get(queueId);
                qwm.members = queueAgents.get(queueId) != null ? queueAgents.get(queueId) : new List<Agent>();
                result.add(qwm);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Erreur lors de la récupération des queues: ' + e.getMessage());
        }
        
        return result;
    }

    /**
     * Récupère les statuts de présence Omnichannel des agents
     */
    @AuraEnabled
    public static List<AgentPresence> getAgentsPresenceStatus(List<String> userIds) {
        List<AgentPresence> result = new List<AgentPresence>();
        
        try {
            // Récupérer les statuts de présence des utilisateurs
            List<ServicePresenceUserStatus> presences = [
                SELECT Id, UserId, ServicePresenceStatusId, 
                       ServicePresenceStatus.Label
                FROM ServicePresenceUserStatus
                WHERE UserId IN :userIds
                ORDER BY UserId
            ];
            
            // Créer une map pour éviter les doublons (garder le dernier)
            Map<String, AgentPresence> presenceMap = new Map<String, AgentPresence>();
            
            for (ServicePresenceUserStatus presence : presences) {
                AgentPresence ap = new AgentPresence();
                ap.userId
