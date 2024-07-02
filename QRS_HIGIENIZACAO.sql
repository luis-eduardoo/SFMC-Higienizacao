                                            /* /////// EDUARDO SOUSA - DATA ATUALIZAÇÃO 07/08/23 /////// */


/* [ETAPA 1] CONTATOS SEM CANAL ==> VOL. XXX.XXX ctts */

==> Nesta etapa basta criar um DataExtract via Automation Studio com o type 'Contact without Channel'

/* [ETAPA 2] CONTATOS DUPLICADOS ==> VOL. XXX.XXX ctts */

SELECT 
    SubscriberKey,
    EmailAddress,
    FLAG
FROM 
    (SELECT 
        SubscriberKey,
        EmailAddress,
        ROW_NUMBER() OVER (PARTITION BY EmailAddress ORDER BY CreatedDate DESC) AS FLAG
    FROM _Subscribers
    ) A
WHERE FLAG >= 2

/* [ETAPA 3] CONTATOS COM "teste" no ENDEREÇO ==> VOL. XXX.XXX ctts */

SELECT 
    SubscriberKey,
    EmailAddress
FROM _Subscribers
WHERE
    EmailAddress LIKE 'teste%'
OR  EmailAddress LIKE '%@teste%'

/* [ETAPA 4] ASSINANTES HARD BOUNCE ==> VOL. XX.XX ctts */

SELECT
    s.SubscriberKey,
    s.EmailAddress,
    b.BounceCategory,
    b.BounceSubcategory
FROM [_Bounce] b
INNER JOIN
    [_Subscribers] s ON b.SubscriberKey = s.SubscriberKey
WHERE
    b.BounceCategory = 'Hard Bounce'
OR
    b.BounceSubcategory IN ('User Unknown', 'Domain Unknown', 'Inactive Account', 'Blocked', 'Unknow')  


/* [ETAPA 5] CONTATOS COM CONTACTKEY IGUAL A TELEFONE => X.XXX ctts */

SELECT
      smsSubLog.LogDate
    , smsSubLog.SubscriberKey
    , smsSubLog.MobileSubscriptionID
    , smsSubLog.SubscriptionDefinitionID
    , smsSubLog.MobileNumber
    , smsSubLog.OptOutStatusID
    , smsSubLog.OptOutMethodID
    , smsSubLog.OptOutDate
    , smsSubLog.OptInStatusID
    , smsSubLog.OptInMethodID
    , smsSubLog.OptInDate
    , smsSubLog.Source
    , smsSubLog.CreatedDate
    , CONVERT(CHAR(10), smsSubLog.ModifiedDate,103) AS DateModifield

FROM 
    _SMSSubscriptionLog AS smsSubLog
WHERE
    smsSubLog.SubscriberKey LIKE '%55%'

/*[ETAPA 6] CONTATOS COM CONTACTKEY IGUAL A EMAIL (se não for a padrão da BU) => X.XXX ctts*/


SELECT 
    SubscriberKey,
    EmailAddress
FROM 
    _Subscribers
WHERE SubscriberKey LIKE '%@%'

/*[ETAPA 6 - NÃO APAGAR] ASSINANTES SEM ENVIO NOS ÚLTIMOS 6 MESES ==> VOL. XX.XXX ctts
  => Nesta etapa é interessante ter a volumetria de assinantes sem envio nos últimos 6 meses para sugerir uma Jornada de Winback/Recuperação de dormentes*/ 

SELECT
    s.SubscriberKey,
    s.SubscriberID,
    s.EmailAddress,
    s.Status,
    s.Domain,
    s.DateUndeliverable,
    s.DateJoined,
    s.DateUnsubscribed,
    s.BounceCount,
    s.SubscriberType,
    s.Locale
FROM 
    [_Subscribers] s
WHERE
    NOT EXISTS
        (
        SELECT
            st.SubscriberKey
        FROM
            [_Sent] st
        WHERE
            s.SubscriberKey = st.SubscriberKey
        )
AND
    STATUS LIKE 'active'
