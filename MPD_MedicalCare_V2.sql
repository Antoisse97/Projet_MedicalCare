alter table ANALYSE_SANG
   drop constraint FK_ANALYSE__SANG_ANAL_FICHE_EX;

alter table DOSSIER
   drop constraint FK_DOSSIER_APPARTIEN_PATIENT;

alter table EEG
   drop constraint FK_EEG_EEG_ANALY_FICHE_EX;

alter table EST_MALADE
   drop constraint FK_EST_MALA_EST_MALAD_DOSSIER;

alter table EST_MALADE
   drop constraint FK_EST_MALA_EST_MALAD_PATHOLOG;

alter table FICHE_EXAM
   drop constraint FK_FICHE_EX_EEG_ANALY_EEG;

alter table FICHE_EXAM
   drop constraint FK_FICHE_EX_INDUIT_FICHE_QU;

alter table FICHE_EXAM
   drop constraint FK_FICHE_EX_SANG_ANAL_ANALYSE_;

alter table FICHE_EXAM
   drop constraint FK_FICHE_EX_TESTEFFOR_TEST_EFF;

alter table FICHE_QUOTIDIENNE
   drop constraint FK_FICHE_QU_APPARTIEN_PATIENT;

alter table LOT_MEDICAMENT
   drop constraint FK_LOT_MEDI_PREND_PATIENT;

alter table PATIENT
   drop constraint FK_PATIENT_APPARTIEN_DOSSIER;

alter table PATIENT
   drop constraint FK_PATIENT_EST_MEDEC_PERSO_ME;

alter table PATIENT
   drop constraint FK_PATIENT_HOSPITALI_CENTRE;

alter table PERSONNEL
   drop constraint FK_PERSONNE_EST_SOIGN_PERSO_ME;

alter table PERSONNEL
   drop constraint FK_PERSONNE_TRAVAILLE_CENTRE;

alter table PERSO_MED
   drop constraint FK_PERSO_ME_EST_SOIGN_PERSONNE;

alter table TEST_EFFORT
   drop constraint FK_TEST_EFF_TESTEFFOR_FICHE_EX;

alter table TRAITE
   drop constraint FK_TRAITE_TRAITE_PERSO_ME;

alter table TRAITE
   drop constraint FK_TRAITE_TRAITE2_FICHE_QU;

drop index SANG_ANALYSE_FK;

drop table ANALYSE_SANG cascade constraints;

drop table CENTRE cascade constraints;

drop index APPARTIENT1_FK;

drop table DOSSIER cascade constraints;

drop index EEG_ANALYSE_FK;

drop table EEG cascade constraints;

drop index EST_MALADE2_FK;

drop index EST_MALADE_FK;

drop table EST_MALADE cascade constraints;

drop index EEG_ANALYSE2_FK;

drop index SANG_ANALYSE2_FK;

drop index INDUIT_FK;

drop table FICHE_EXAM cascade constraints;

drop index APPARTIENT3_FK;

drop table FICHE_QUOTIDIENNE cascade constraints;

drop index PREND_FK;

drop table LOT_MEDICAMENT cascade constraints;

drop table PATHOLOGIE cascade constraints;

drop index EST_MEDECIN_FK;

drop index APPARTIENT2_FK;

drop index HOSPITALISE_FK;

drop table PATIENT cascade constraints;

drop index TRAVAILLE_FK;

drop index EST_SOIGNANT_FK;

drop table PERSONNEL cascade constraints;

drop index EST_SOIGNANT2_FK;

drop table PERSO_MED cascade constraints;

drop index TESTEFFORT_ANALYSE_FK;

drop table TEST_EFFORT cascade constraints;

drop index TRAITE2_FK;

drop index TRAITE_FK;

drop table TRAITE cascade constraints;

/*==============================================================*/
/* Table : ANALYSE_SANG                                         */
/*==============================================================*/
create table ANALYSE_SANG 
(
   ID_EXAM              NUMBER               not null,
   CHOLESTEROL          NUMBER               not null,
   GLYCEMIE             CHAR(10)             not null,
   PLAQUETTE            CHAR(10)             not null,
   HEMOGLOBINE          CHAR(10)             not null,
   ERYTHROCYTES         CHAR(10)             not null,
   LEUCOCYTES           CHAR(10)             not null
);

/*==============================================================*/
/* Index : SANG_ANALYSE_FK                                      */
/*==============================================================*/
create index SANG_ANALYSE_FK on ANALYSE_SANG (
   ID_EXAM ASC
);

/*==============================================================*/
/* Table : CENTRE                                               */
/*==============================================================*/
create table CENTRE 
(
   ID_CENTRE            NUMBER               not null,
   constraint PK_CENTRE primary key (ID_CENTRE)
);

/*==============================================================*/
/* Table : DOSSIER                                              */
/*==============================================================*/
create table DOSSIER 
(
   LIGNE_DOSSIER        NUMBER               not null,
   ID_PATIENT           NUMBER               not null,
   ACTE_MEDICAL         CHAR(10)             not null
      constraint CKC_ACTE_MEDICAL_DOSSIER check (ACTE_MEDICAL in ('1','0')),
   constraint PK_DOSSIER primary key (LIGNE_DOSSIER)
);

/*==============================================================*/
/* Index : APPARTIENT1_FK                                       */
/*==============================================================*/
create index APPARTIENT1_FK on DOSSIER (
   ID_PATIENT ASC
);

/*==============================================================*/
/* Table : EEG                                                  */
/*==============================================================*/
create table EEG 
(
   RESULTAT_EEG         NUMBER               not null,
   ID_EXAM              NUMBER               not null,
   constraint PK_EEG primary key (RESULTAT_EEG)
);

/*==============================================================*/
/* Index : EEG_ANALYSE_FK                                       */
/*==============================================================*/
create index EEG_ANALYSE_FK on EEG (
   ID_EXAM ASC
);

/*==============================================================*/
/* Table : EST_MALADE                                           */
/*==============================================================*/
create table EST_MALADE 
(
   LIGNE_DOSSIER        NUMBER               not null,
   NOM_PATHO            VARCHAR2(50)         not null,
   constraint PK_EST_MALADE primary key (LIGNE_DOSSIER, NOM_PATHO)
);

/*==============================================================*/
/* Index : EST_MALADE_FK                                        */
/*==============================================================*/
create index EST_MALADE_FK on EST_MALADE (
   LIGNE_DOSSIER ASC
);

/*==============================================================*/
/* Index : EST_MALADE2_FK                                       */
/*==============================================================*/
create index EST_MALADE2_FK on EST_MALADE (
   NOM_PATHO ASC
);

/*==============================================================*/
/* Table : FICHE_EXAM                                           */
/*==============================================================*/
create table FICHE_EXAM 
(
   ID_EXAM              NUMBER               not null,
   RESULTAT_EEG         NUMBER,
   NUMJ                 NUMBER               not null,
   TYPE_EXAMEN          VARCHAR2(100)        not null,
   DATEPRESCRIPTION     DATE                 not null,
   VALIDE               NUMBER(1)            not null
      constraint CKC_VALIDE_FICHE_EX check (VALIDE in (1,2)),
   DATEREALISATION      DATE,
   constraint PK_FICHE_EXAM primary key (ID_EXAM)
);

/*==============================================================*/
/* Index : INDUIT_FK                                            */
/*==============================================================*/
create index INDUIT_FK on FICHE_EXAM (
   NUMJ ASC
);

/*==============================================================*/
/* Index : SANG_ANALYSE2_FK                                     */
/*==============================================================*/
create index SANG_ANALYSE2_FK on FICHE_EXAM (
   
);

/*==============================================================*/
/* Index : EEG_ANALYSE2_FK                                      */
/*==============================================================*/
create index EEG_ANALYSE2_FK on FICHE_EXAM (
   RESULTAT_EEG ASC
);

/*==============================================================*/
/* Table : FICHE_QUOTIDIENNE                                    */
/*==============================================================*/
create table FICHE_QUOTIDIENNE 
(
   NUMJ                 NUMBER               not null,
   ID_PATIENT           NUMBER               not null,
   NUMCHAMBRE           NUMBER               not null,
   NUMPATIENT           NUMBER               not null,
   POIDSJ               NUMBER               not null,
   P_ARTERIELJ          NUMBER               not null,
   RYTHCARDJ            NUMBER               not null,
   TEMPERATUREJ         NUMBER               not null,
   OBSJ                 VARCHAR2(1000),
   INFOINFIRMIERE       VARCHAR2(1000),
   constraint PK_FICHE_QUOTIDIENNE primary key (NUMJ)
);

/*==============================================================*/
/* Index : APPARTIENT3_FK                                       */
/*==============================================================*/
create index APPARTIENT3_FK on FICHE_QUOTIDIENNE (
   ID_PATIENT ASC
);

/*==============================================================*/
/* Table : LOT_MEDICAMENT                                       */
/*==============================================================*/
create table LOT_MEDICAMENT 
(
   NUMLOTS              NUMBER               not null,
   ID_PATIENT           NUMBER               not null,
   constraint PK_LOT_MEDICAMENT primary key (NUMLOTS)
);

/*==============================================================*/
/* Index : PREND_FK                                             */
/*==============================================================*/
create index PREND_FK on LOT_MEDICAMENT (
   ID_PATIENT ASC
);

/*==============================================================*/
/* Table : PATHOLOGIE                                           */
/*==============================================================*/
create table PATHOLOGIE 
(
   NOM_PATHO            VARCHAR2(50)         not null,
   EXCLUANTE            CHAR(10)             not null
      constraint CKC_EXCLUANTE_PATHOLOG check (EXCLUANTE >= '3' and EXCLUANTE in ('oui','non')),
   constraint PK_PATHOLOGIE primary key (NOM_PATHO)
);

/*==============================================================*/
/* Table : PATIENT                                              */
/*==============================================================*/
create table PATIENT 
(
   ID_PATIENT           NUMBER               not null,
   NUM_ADELI            NUMBER(10)           not null,
   LIGNE_DOSSIER        NUMBER,
   ID_CENTRE            NUMBER               not null,
   NOM                  VARCHAR2(50)         not null,
   TRAITEMENT           VARCHAR2(40)         not null,
   DATEDENAISSANCE      DATE                 not null,
   POIDS                NUMBER(3)            not null,
   TAILLE               NUMBER(3)            not null,
   IMC                  NUMBER,
   SEXE                 VARCHAR2(1)          not null
      constraint CKC_SEXE_PATIENT check (SEXE >= '1' and SEXE in ('H','F')),
   GROUPE               VARCHAR2(2)          not null
      constraint CKC_GROUPE_PATIENT check (GROUPE in ('TV','TP','VP','PP')),
   SOUS_GROUPE          VARCHAR2(1)         
      constraint CKC_SOUS_GROUPE_PATIENT check (SOUS_GROUPE is null or (SOUS_GROUPE in ('1','2','3'))),
   constraint PK_PATIENT primary key (ID_PATIENT)
);

/*==============================================================*/
/* Index : HOSPITALISE_FK                                       */
/*==============================================================*/
create index HOSPITALISE_FK on PATIENT (
   ID_CENTRE ASC
);

/*==============================================================*/
/* Index : APPARTIENT2_FK                                       */
/*==============================================================*/
create index APPARTIENT2_FK on PATIENT (
   LIGNE_DOSSIER ASC
);

/*==============================================================*/
/* Index : EST_MEDECIN_FK                                       */
/*==============================================================*/
create index EST_MEDECIN_FK on PATIENT (
   NUM_ADELI ASC
);

/*==============================================================*/
/* Table : PERSONNEL                                            */
/*==============================================================*/
create table PERSONNEL 
(
   ID_PERSO             NUMBER               not null,
   ID_CENTRE            NUMBER               not null,
   NUM_ADELI            NUMBER(10),
   NOM                  VARCHAR2(50)         not null,
   ROLE                 VARCHAR2(30)         not null,
   constraint PK_PERSONNEL primary key (ID_PERSO)
);

/*==============================================================*/
/* Index : EST_SOIGNANT_FK                                      */
/*==============================================================*/
create index EST_SOIGNANT_FK on PERSONNEL (
   NUM_ADELI ASC
);

/*==============================================================*/
/* Index : TRAVAILLE_FK                                         */
/*==============================================================*/
create index TRAVAILLE_FK on PERSONNEL (
   ID_CENTRE ASC
);

/*==============================================================*/
/* Table : PERSO_MED                                            */
/*==============================================================*/
create table PERSO_MED 
(
   NUM_ADELI            NUMBER(10)           not null,
   ID_PERSO             NUMBER               not null,
   SPECIALITE           VARCHAR2(30)         not null,
   SERVICE              VARCHAR2(100)       
      constraint CKC_SERVICE_PERSO_ME check (SERVICE is null or (SERVICE in ('Electro-encéphalogramme','Prise de sang et des résultats d''analyse','Test d''effort'))),
   constraint PK_PERSO_MED primary key (NUM_ADELI)
);

/*==============================================================*/
/* Index : EST_SOIGNANT2_FK                                     */
/*==============================================================*/
create index EST_SOIGNANT2_FK on PERSO_MED (
   ID_PERSO ASC
);

/*==============================================================*/
/* Table : TEST_EFFORT                                          */
/*==============================================================*/
create table TEST_EFFORT 
(
   ID_EXAM              NUMBER               not null,
   RC_AVANT             NUMBER               not null,
   RC_APRES             NUMBER               not null,
   RC_1MIN              NUMBER               not null
);

/*==============================================================*/
/* Index : TESTEFFORT_ANALYSE_FK                                */
/*==============================================================*/
create index TESTEFFORT_ANALYSE_FK on TEST_EFFORT (
   ID_EXAM ASC
);

/*==============================================================*/
/* Table : TRAITE                                               */
/*==============================================================*/
create table TRAITE 
(
   NUM_ADELI            NUMBER(10)           not null,
   NUMJ                 NUMBER               not null,
   constraint PK_TRAITE primary key (NUM_ADELI, NUMJ)
);

/*==============================================================*/
/* Index : TRAITE_FK                                            */
/*==============================================================*/
create index TRAITE_FK on TRAITE (
   NUM_ADELI ASC
);

/*==============================================================*/
/* Index : TRAITE2_FK                                           */
/*==============================================================*/
create index TRAITE2_FK on TRAITE (
   NUMJ ASC
);

alter table ANALYSE_SANG
   add constraint FK_ANALYSE__SANG_ANAL_FICHE_EX foreign key (ID_EXAM)
      references FICHE_EXAM (ID_EXAM);

alter table DOSSIER
   add constraint FK_DOSSIER_APPARTIEN_PATIENT foreign key (ID_PATIENT)
      references PATIENT (ID_PATIENT);

alter table EEG
   add constraint FK_EEG_EEG_ANALY_FICHE_EX foreign key (ID_EXAM)
      references FICHE_EXAM (ID_EXAM);

alter table EST_MALADE
   add constraint FK_EST_MALA_EST_MALAD_DOSSIER foreign key (LIGNE_DOSSIER)
      references DOSSIER (LIGNE_DOSSIER);

alter table EST_MALADE
   add constraint FK_EST_MALA_EST_MALAD_PATHOLOG foreign key (NOM_PATHO)
      references PATHOLOGIE (NOM_PATHO);

alter table FICHE_EXAM
   add constraint FK_FICHE_EX_EEG_ANALY_EEG foreign key (RESULTAT_EEG)
      references EEG (RESULTAT_EEG);

alter table FICHE_EXAM
   add constraint FK_FICHE_EX_INDUIT_FICHE_QU foreign key (NUMJ)
      references FICHE_QUOTIDIENNE (NUMJ);

alter table FICHE_EXAM
   add constraint FK_FICHE_EX_SANG_ANAL_ANALYSE_ foreign key ()
      references ANALYSE_SANG;

alter table FICHE_EXAM
   add constraint FK_FICHE_EX_TESTEFFOR_TEST_EFF foreign key ()
      references TEST_EFFORT;

alter table FICHE_QUOTIDIENNE
   add constraint FK_FICHE_QU_APPARTIEN_PATIENT foreign key (ID_PATIENT)
      references PATIENT (ID_PATIENT);

alter table LOT_MEDICAMENT
   add constraint FK_LOT_MEDI_PREND_PATIENT foreign key (ID_PATIENT)
      references PATIENT (ID_PATIENT);

alter table PATIENT
   add constraint FK_PATIENT_APPARTIEN_DOSSIER foreign key (LIGNE_DOSSIER)
      references DOSSIER (LIGNE_DOSSIER);

alter table PATIENT
   add constraint FK_PATIENT_EST_MEDEC_PERSO_ME foreign key (NUM_ADELI)
      references PERSO_MED (NUM_ADELI);

alter table PATIENT
   add constraint FK_PATIENT_HOSPITALI_CENTRE foreign key (ID_CENTRE)
      references CENTRE (ID_CENTRE);

alter table PERSONNEL
   add constraint FK_PERSONNE_EST_SOIGN_PERSO_ME foreign key (NUM_ADELI)
      references PERSO_MED (NUM_ADELI);

alter table PERSONNEL
   add constraint FK_PERSONNE_TRAVAILLE_CENTRE foreign key (ID_CENTRE)
      references CENTRE (ID_CENTRE);

alter table PERSO_MED
   add constraint FK_PERSO_ME_EST_SOIGN_PERSONNE foreign key (ID_PERSO)
      references PERSONNEL (ID_PERSO);

alter table TEST_EFFORT
   add constraint FK_TEST_EFF_TESTEFFOR_FICHE_EX foreign key (ID_EXAM)
      references FICHE_EXAM (ID_EXAM);

alter table TRAITE
   add constraint FK_TRAITE_TRAITE_PERSO_ME foreign key (NUM_ADELI)
      references PERSO_MED (NUM_ADELI);

alter table TRAITE
   add constraint FK_TRAITE_TRAITE2_FICHE_QU foreign key (NUMJ)
      references FICHE_QUOTIDIENNE (NUMJ);
