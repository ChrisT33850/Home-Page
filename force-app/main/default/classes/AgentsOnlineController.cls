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
            List<GroupMember> members = [
                SELECT GroupId, Group.Name, Group.Id, UserOrGroupId
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
            
            List<GroupMember> queueMembers = [
                SELECT GroupId, UserOrGroupId, User.Id, User.Name, User.SmallPhotoUrl, User.FirstName
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

    @AuraEnabled
    public static List<AgentPresence> getAgentsPresenceStatus(List<String> userIds) {
        List<AgentPresence> result = new List<AgentPresence>();
        
        try {
            List<ServicePresenceUserStatus> presences = [
                SELECT Id, UserId, ServicePresenceStatusId, ServicePresenceStatus.Label
                FROM ServicePresenceUserStatus
                WHERE UserId IN :userIds
                ORDER BY UserId
            ];
            
            Map<String, AgentPresence> presenceMap = new Map<String, AgentPresence>();
            
            for (ServicePresenceUserStatus presence : presences) {
                AgentPresence ap = new AgentPresence();
                ap.userId = presence.UserId;
                ap.statusId = presence.ServicePresenceStatusId;
                ap.statusName = presence.ServicePresenceStatus.Label;
                presenceMap.put(presence.UserId, ap);
            }
            
            for (String userId : userIds) {
                if (!presenceMap.containsKey(userId)) {
                    AgentPresence ap = new AgentPresence();
                    ap.userId = userId;
                    ap.statusId = null;
                    ap.statusName = 'Offline';
                    presenceMap.put(userId, ap);
                }
            }
            
            result.addAll(presenceMap.values());
            
        } catch (Exception e) {
            System.debug('Error getting presence status: ' + e.getMessage());
            for (String userId : userIds) {
                AgentPresence ap = new AgentPresence();
                ap.userId = userId;
                ap.statusId = null;
                ap.statusName = 'Offline';
                result.add(ap);
            }
        }
        
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<StatusOption> getOmnichanelPresenceStatuses() {
        List<StatusOption> result = new List<StatusOption>();
        
        try {
            List<ServicePresenceStatus> statuses = [
                SELECT Id, Label
                FROM ServicePresenceStatus
                WHERE IsActive = true
                ORDER BY Label
            ];
            
            for (ServicePresenceStatus status : statuses) {
                StatusOption so = new StatusOption();
                so.Id = status.Id;
                so.Label = status.Label;
                result.add(so);
            }
            
        } catch (Exception e) {
            System.debug('Error getting presence statuses: ' + e.getMessage());
        }
        
        return result;
    }

    public class QueueWithMembers {
        @AuraEnabled public Id queueId { get; set; }
        @AuraEnabled public String queueName { get; set; }
        @AuraEnabled public List<Agent> members { get; set; }
    }
    
    public class Agent {
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String photoUrl { get; set; }
        @AuraEnabled public String initials { get; set; }
    }
    
    public class AgentPresence {
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String statusId { get; set; }
        @AuraEnabled public String statusName { get; set; }
    }
    
    public class StatusOption {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Label { get; set; }
    }
}
