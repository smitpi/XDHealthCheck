﻿
$script:RegistrationState = @{
    0 = 'Unknown'
    1 = 'Registered'
    2 = 'Unregistered'
}
$script:ConnectionState = @{
    0 = 'Unknown'
    1 = 'Connected'
    2 = 'Disconnected'
    3 = 'Terminated'
    4 = 'PreparingSession'
    5 = 'Active'
    6 = 'Reconnecting'
    7 = 'NonBrokeredSession'
    8 = 'Other'
    9 = 'Pending'
}
$script:ConnectionFailureType = @{
    0 = 'None'
    1 = 'ClientConnectionFailure'
    2 = 'MachineFailure'
    3 = 'NoCapacityAvailable'
    4 = 'NoLicensesAvailable'
    5 = 'Configuration'
}
$script:SessionFailureCode = @{
    0   = 'Unknown'
    1   = 'None'
    2   = 'SessionPreparation'
    3   = 'RegistrationTimeout'
    4   = 'ConnectionTimeout'
    5   = 'Licensing'
    6   = 'Ticketing'
    7   = 'Other'
    8   = 'GeneralFail'
    9   = 'MaintenanceMode'
    10  = 'ApplicationDisabled'
    11  = 'LicenseFeatureRefused'
    12  = 'NoDesktopAvailable'
    13  = 'SessionLimitReached'
    14  = 'DisallowedProtocol'
    15  = 'ResourceUnavailable'
    16  = 'ActiveSessionReconnectDisabled'
    17  = 'NoSessionToReconnect'
    18  = 'SpinUpFailed'
    19  = 'Refused'
    20  = 'ConfigurationSetFailure'
    21  = 'MaxTotalInstancesExceeded'
    22  = 'MaxPerUserInstancesExceeded'
    23  = 'CommunicationError'
    24  = 'MaxPerMachineInstancesExceeded'
    25  = 'MaxPerEntitlementInstancesExceeded'
    100 = 'NoMachineAvailable'
    101 = 'MachineNotFunctional'
}
$global:MachineDeregistration = @{
    0   = 'AgentShutdown'
    1   = 'AgentSuspended'
    100	= 'IncompatibleVersion'
    101	= 'AgentAddressResolutionFailed'
    102	= 'AgentNotContactable'
    103	= 'AgentWrongActiveDirectoryOU'
    104	= 'EmptyRegistrationRequest'
    105	= 'MissingRegistrationCapabilities'
    106	= 'MissingAgentVersion'
    107	= 'InconsistentRegistrationCapabilities'
    108	= 'NotLicensedForFeature'
    109	= 'UnsupportedCredentialSecurityversion'
    110	= 'InvalidRegistrationRequest'
    111	= 'SingleMultiSessionMismatch'
    112	= 'FunctionalLevelTooLowForCatalog'
    113	= 'FunctionalLevelTooLowForDesktopGroup'
    200	= 'PowerOff'
    203	= 'AgentRejectedSettingsUpdate'
    206	= 'SessionPrepareFailure'
    207	= 'ContactLost'
    301	= 'BrokerRegistrationLimitReached'
    208	= 'SettingsCreationFailure'
    204	= 'SendSettingsFailure'
    2   = 'AgentRequested'
    201	= 'DesktopRestart'
    202	= 'DesktopRemoved'
    205	= 'SessionAuditFailure'
    300	= 'UnknownError'
    302	= 'RegistrationStateMismatch'
}
$script:MachineFailureType = @{
    4 = 'MaxCapacity'
    2 = 'StuckOnBoot'	
    1 = 'FailedToStart'
}
$script:ConnectionState = @{
    0   =	'Unknown'
    1	=	'Connected'
    2	=	'Disconnected'
    3	=	'Terminated'
    4	=	'PreparingSession'
    5	=	'Active'
    6	=	'Reconnecting'
    7	=	'NonBrokeredSession'
    8	=	'Other'
    9	=	'Pending'
}

AllocationType
AssignedCount
AvailableAssignedCount
AvailableCount
AvailableUnassignedCount
CatalogName
Description
MinimumFunctionalLevel
PersistUserChanges
ProvisioningType
PvsAddress
PvsDomain
Scopes
SessionSupport
UnassignedCount
UsedCount

 Get-BrokerCatalog -AdminAddress $ctxddc | Select-Object CatalogName,AllocationType,MinimumFunctionalLevel,PersistUserChanges,ProvisioningType,Scopes,SessionSupport,AssignedCount,AvailableAssignedCount,AvailableCount,AvailableUnassignedCount,UnassignedCount,UsedCount,Description,PvsAddress,PvsDomain