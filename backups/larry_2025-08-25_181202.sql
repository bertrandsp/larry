--
-- PostgreSQL database dump
--

\restrict doAOB8HU63iEucrUHohRI1pbvXrxc6xynuP5NqegTyfk4WUbwalbKdAmHzOLGK2

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- Name: Difficulty; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Difficulty" AS ENUM (
    'easy',
    'medium',
    'hard'
);


--
-- Name: FriendshipLevel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."FriendshipLevel" AS ENUM (
    'new',
    'friend',
    'close_friend',
    'buddy'
);


--
-- Name: NotifyFrequency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."NotifyFrequency" AS ENUM (
    'daily',
    'every_other',
    'weekly',
    'twice_daily',
    'thrice_daily'
);


--
-- Name: Persona; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Persona" AS ENUM (
    'LARRY'
);


--
-- Name: PersonaMood; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PersonaMood" AS ENUM (
    'curious',
    'excited',
    'fascinated'
);


--
-- Name: RecommendationSource; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RecommendationSource" AS ENUM (
    'PERSONA',
    'SYSTEM',
    'CURATED',
    'SPACED_REVIEW'
);


--
-- Name: ReviewStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ReviewStatus" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Favorite; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Favorite" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "termId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reason text
);


--
-- Name: GraphEdge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."GraphEdge" (
    id text NOT NULL,
    "fromTermId" text NOT NULL,
    "toTermId" text NOT NULL,
    relationship text NOT NULL,
    strength double precision DEFAULT 1.0 NOT NULL,
    source text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Interest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Interest" (
    id text NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    locale text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status text
);


--
-- Name: InterestAnnotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."InterestAnnotation" (
    id text NOT NULL,
    "interestId" text NOT NULL,
    persona public."Persona" NOT NULL,
    story text,
    mood public."PersonaMood" DEFAULT 'curious'::public."PersonaMood" NOT NULL
);


--
-- Name: OAuthState; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."OAuthState" (
    id text NOT NULL,
    state text NOT NULL,
    provider text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text
);


--
-- Name: PersonaRelationship; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."PersonaRelationship" (
    id text NOT NULL,
    "userId" text NOT NULL,
    persona public."Persona" NOT NULL,
    nickname text,
    "daysTogether" integer DEFAULT 0 NOT NULL,
    level public."FriendshipLevel" DEFAULT 'new'::public."FriendshipLevel" NOT NULL,
    "consecutiveDaysTogether" integer DEFAULT 0 NOT NULL
);


--
-- Name: Profile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Profile" (
    "userId" text NOT NULL,
    username text,
    tier text DEFAULT 'free'::text NOT NULL,
    "notifyFrequency" public."NotifyFrequency",
    "notifyLocalHHmm" text,
    "notifyLocalTz" text,
    "notifyUtcTime" timestamp(3) without time zone,
    "pushToken" text
);


--
-- Name: Recommendation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Recommendation" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "termId" text NOT NULL,
    source public."RecommendationSource" NOT NULL,
    persona public."Persona",
    "recommendedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "openedAt" timestamp(3) without time zone,
    reaction text,
    message text
);


--
-- Name: Review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Review" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "termId" text NOT NULL,
    bucket integer DEFAULT 1 NOT NULL,
    mastered boolean DEFAULT false NOT NULL,
    "nextAt" timestamp(3) without time zone NOT NULL,
    note text
);


--
-- Name: ReviewItem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."ReviewItem" (
    id text NOT NULL,
    "termId" text,
    "candId" text,
    reason text NOT NULL,
    status public."ReviewStatus" DEFAULT 'pending'::public."ReviewStatus" NOT NULL,
    notes text,
    content jsonb,
    source text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "reviewedAt" timestamp(3) without time zone,
    "reviewedBy" text
);


--
-- Name: Tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Tag" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    color text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Term; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Term" (
    id text NOT NULL,
    term text NOT NULL,
    definition text NOT NULL,
    examples jsonb NOT NULL,
    "similar" jsonb NOT NULL,
    "interestId" text NOT NULL,
    difficulty public."Difficulty" DEFAULT 'easy'::public."Difficulty" NOT NULL,
    "isRefined" boolean DEFAULT false NOT NULL,
    "qualityMetrics" jsonb,
    "selfQualityRating" double precision,
    "userQualityRating" double precision
);


--
-- Name: TermAnnotation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TermAnnotation" (
    id text NOT NULL,
    "termId" text NOT NULL,
    persona public."Persona" NOT NULL,
    note text,
    "sourceHint" text,
    enthusiasm integer DEFAULT 5 NOT NULL
);


--
-- Name: TermTag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TermTag" (
    id text NOT NULL,
    "termId" text NOT NULL,
    "tagId" text NOT NULL,
    confidence double precision DEFAULT 1.0 NOT NULL
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    name text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    avatar text,
    "lastLoginAt" timestamp(3) without time zone,
    provider text
);


--
-- Name: UserInterest; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserInterest" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "interestId" text NOT NULL,
    "overlapScore" integer NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    since timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Data for Name: Favorite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Favorite" (id, "userId", "termId", "createdAt", reason) FROM stdin;
\.


--
-- Data for Name: GraphEdge; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."GraphEdge" (id, "fromTermId", "toTermId", relationship, strength, source, "createdAt") FROM stdin;
\.


--
-- Data for Name: Interest; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Interest" (id, slug, name, description, locale, "createdAt", status) FROM stdin;
cmersives00001hwrrjmq0vig	technology	Technology	Software, hardware, and digital innovation	en	2025-08-26 00:10:59.333	global
cmersivf100011hwr608lmd7m	science	Science	Scientific discoveries and research	en	2025-08-26 00:10:59.341	global
cmersivf300021hwrerbjqo3y	business	Business	Entrepreneurship, management, and commerce	en	2025-08-26 00:10:59.344	global
cmersivf600031hwr3ohkyu36	health-fitness	Health & Fitness	Physical and mental wellness	en	2025-08-26 00:10:59.346	global
cmersivf800041hwrqscv8j8n	travel	Travel	Exploring new places and cultures	en	2025-08-26 00:10:59.348	global
cmersivfa00051hwrgue8tsg3	cooking	Cooking	Culinary arts and food preparation	en	2025-08-26 00:10:59.35	global
cmersivfb00061hwr7qh6blfm	music	Music	Musical instruments, theory, and appreciation	en	2025-08-26 00:10:59.352	global
cmersivfd00071hwrvlwi3hse	sports	Sports	Athletics, games, and physical activities	en	2025-08-26 00:10:59.354	global
cmersivfg00081hwrk2gkvwsp	art-design	Art & Design	Creative expression and visual arts	en	2025-08-26 00:10:59.357	global
cmersivfi00091hwrfghd06tj	literature	Literature	Books, writing, and storytelling	en	2025-08-26 00:10:59.359	global
cmersivfl000a1hwr2o1tul0t	history	History	Past events and historical knowledge	en	2025-08-26 00:10:59.361	global
cmersivfm000b1hwrakbsp0bl	psychology	Psychology	Human behavior and mental processes	en	2025-08-26 00:10:59.363	global
cmersivfo000c1hwrag8mgd81	finance	Finance	Money management and investment	en	2025-08-26 00:10:59.365	global
cmersivfq000d1hwrp6xle5j9	education	Education	Learning and academic pursuits	en	2025-08-26 00:10:59.366	global
cmersivfs000e1hwrvlaapv3x	environment	Environment	Nature, sustainability, and ecology	en	2025-08-26 00:10:59.368	global
cmeruh04a001c1hg8zbnkgw0y	health-&-fitness	Health-&-fitness	Generated vocabulary for health-&-fitness	en	2025-08-26 01:05:31.354	\N
\.


--
-- Data for Name: InterestAnnotation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."InterestAnnotation" (id, "interestId", persona, story, mood) FROM stdin;
\.


--
-- Data for Name: OAuthState; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."OAuthState" (id, state, provider, "expiresAt", "createdAt", "userId") FROM stdin;
\.


--
-- Data for Name: PersonaRelationship; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."PersonaRelationship" (id, "userId", persona, nickname, "daysTogether", level, "consecutiveDaysTogether") FROM stdin;
\.


--
-- Data for Name: Profile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Profile" ("userId", username, tier, "notifyFrequency", "notifyLocalHHmm", "notifyLocalTz", "notifyUtcTime", "pushToken") FROM stdin;
001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	appleuser	free	every_other	11:00	America/Los_Angeles	2025-08-25 18:00:00	\N
\.


--
-- Data for Name: Recommendation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Recommendation" (id, "userId", "termId", source, persona, "recommendedAt", "openedAt", reaction, message) FROM stdin;
\.


--
-- Data for Name: Review; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Review" (id, "userId", "termId", bucket, mastered, "nextAt", note) FROM stdin;
\.


--
-- Data for Name: ReviewItem; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."ReviewItem" (id, "termId", "candId", reason, status, notes, content, source, "createdAt", "reviewedAt", "reviewedBy") FROM stdin;
\.


--
-- Data for Name: Tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Tag" (id, name, description, color, "createdAt") FROM stdin;
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, term, definition, examples, "similar", "interestId", difficulty, "isRefined", "qualityMetrics", "selfQualityRating", "userQualityRating") FROM stdin;
cmert956z000f1hg8u846raub	Business"	Business"	["...an business program\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1...", "...an business program\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1..."]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmert9572000h1hg87xg7t6ig	song),	song),	["...\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1980\\nThe Business...", "...\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1980\\nThe Business..."]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmert956w000d1hg8yha84vmt	Corporations	distinct from sole proprietors and partnerships	["Corporations are distinct from sole proprietors and partnerships", "Corporations are separate and unique legal entities from their shareholders; as such they provide limited liability for their owners and members"]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmert956b00091hg854d3cy6l	business	business	["A business entity is not necessarily separate from the owner...", "A business entity is not necessarily separate from the owner..."]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmert956k000b1hg8cwhnyhie	Business	the practice of making one's living or making money by producing or buying and selling products (suc...	["Business is the practice of making one's living or making money by producing or buying and selling products (such as goods and services", "The Business may refer to:\\n\\nThe Business (magazine), a British weekly magazine\\nThe Business (band), an English punk rock/Oi"]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmeruh04u001k1hg8we48f8t1	exercise	exercise	["Many people choose to exercise outdoors where they can congregate in groups, socialize, and improve well-being as well as mental health", "In terms of health benefits, usually, 150 minutes of moderate-intensity exercise per week is recommended for reducing the risk of health problems"]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmeruh04y001m1hg8n1stwest	fitness	a state of health and well-being and, more specifically, the ability to perform aspects of sports, o...	["Physical fitness is a state of health and well-being and, more spe...", "Physical fitness is generally achieved through proper nutrition, m..."]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmeruh04s001i1hg8r6fk2uoz	health	health	["Exercise or working out is physical activity that enhances or maintains fitness and overall health", "Many people choose to exercise outdoors where they can congregate in groups, socialize, and improve well-being as well as mental health"]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmeruh04g001e1hg8erds8kj0	Microsoft	Microsoft	["MSN is a web portal and related collection of Internet services and apps provided by Microsoft", "...t curated from hundreds of different sources that Microsoft has partnered with"]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
cmeruh04k001g1hg8oddiqk32	Internet	Internet	["MSN is a web portal and related collection of Internet services and apps provided by Microsoft", "... called The Microsoft Network; it later became an Internet service provider named MSN Dial-Up Internet Acces..."]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N
\.


--
-- Data for Name: TermAnnotation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TermAnnotation" (id, "termId", persona, note, "sourceHint", enthusiasm) FROM stdin;
\.


--
-- Data for Name: TermTag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TermTag" (id, "termId", "tagId", confidence) FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, name, "createdAt", avatar, "lastLoginAt", provider) FROM stdin;
001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	dwb7jwhqw9@privaterelay.appleid.com		2025-08-26 00:22:06.991	\N	2025-08-26 00:31:39.278	apple
\.


--
-- Data for Name: UserInterest; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserInterest" (id, "userId", "interestId", "overlapScore", enabled, since) FROM stdin;
cmerugz1200191hg8zlohnu3h	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfm000b1hwrakbsp0bl	50	t	2025-08-26 01:05:29.942
cmert9vap00131hg8xxw6q9ef	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf600031hwr3ohkyu36	50	t	2025-08-26 00:31:58.897
cmert3h8s00011hg82bjrwy5n	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfg00081hwrk2gkvwsp	0	f	2025-08-26 00:27:00.747
cmert3h8u00031hg8yj56zqmu	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfq000d1hwrp6xle5j9	0	f	2025-08-26 00:27:00.75
cmert945l00051hg80ck1at6g	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf300021hwrerbjqo3y	0	f	2025-08-26 00:31:23.721
cmert945p00071hg86v3twq6l	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfs000e1hwrvlaapv3x	0	f	2025-08-26 00:31:23.725
cmert9va7000j1hg87dv64aci	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf800041hwrqscv8j8n	0	f	2025-08-26 00:31:58.879
cmert9va8000l1hg8tn87ix2g	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf100011hwr608lmd7m	0	f	2025-08-26 00:31:58.88
cmert9va9000n1hg8n0w8bf84	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfl000a1hwr2o1tul0t	0	f	2025-08-26 00:31:58.881
cmert9val000t1hg8rbw5jyd0	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfa00051hwrgue8tsg3	0	f	2025-08-26 00:31:58.889
cmert9vam000v1hg8kpbusg67	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfo000c1hwrag8mgd81	0	f	2025-08-26 00:31:58.894
cmert9van000x1hg8c6hyuual	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfi00091hwrfghd06tj	0	f	2025-08-26 00:31:58.895
cmert9vaq00151hg81wniebqu	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfb00061hwr7qh6blfm	0	f	2025-08-26 00:31:58.898
cmert9var00171hg8x2ef6xj3	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfd00071hwrvlwi3hse	0	f	2025-08-26 00:31:58.899
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
630f5210-3df5-4930-a95b-0e5243abafa9	e4bb1f3a73c02cae12fc15baa5a8ea4cafd41c1dc4fffa5ff96680ea9d7b5024	2025-08-26 00:10:29.139746+00	20250810003302_init	\N	\N	2025-08-26 00:10:29.117559+00	1
1ad87b09-bb8b-41ba-9a7e-1aea9600e94d	c25220ca1dc88293fdf4fb1ccf39dfbdad478d3ecf2313f2374de80f160f01ef	2025-08-26 00:10:29.165362+00	20250811022113_persona_overlay_architecture	\N	\N	2025-08-26 00:10:29.140668+00	1
c9e0f9a4-f87d-4f47-98d2-6d22f641b9e9	2e3e5aee500b696255316724af56292ad18d1624cd7872cc7cb5b74b18731928	2025-08-26 00:10:29.168161+00	20250811022404_add_consecutive_days_streak	\N	\N	2025-08-26 00:10:29.166098+00	1
cdd37d69-a267-489d-885f-23fef14d4054	0f6f7207e8c17ce9bbceb0bde9e24245ee3923d35d866bc47fcd269d44a4608c	2025-08-26 00:10:29.191256+00	20250825200911_add_profile_notifications	\N	\N	2025-08-26 00:10:29.168866+00	1
399ce05a-53b1-4d1d-b42e-bf36e1195483	91da68da95e24646941f1f6da4842bd0cde0628474a31af8e4fa9bba022627e6	2025-08-26 00:10:29.193974+00	20250825235858_add_new_frequency_options	\N	\N	2025-08-26 00:10:29.191886+00	1
\.


--
-- Name: Favorite Favorite_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Favorite"
    ADD CONSTRAINT "Favorite_pkey" PRIMARY KEY (id);


--
-- Name: GraphEdge GraphEdge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GraphEdge"
    ADD CONSTRAINT "GraphEdge_pkey" PRIMARY KEY (id);


--
-- Name: InterestAnnotation InterestAnnotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InterestAnnotation"
    ADD CONSTRAINT "InterestAnnotation_pkey" PRIMARY KEY (id);


--
-- Name: Interest Interest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Interest"
    ADD CONSTRAINT "Interest_pkey" PRIMARY KEY (id);


--
-- Name: OAuthState OAuthState_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OAuthState"
    ADD CONSTRAINT "OAuthState_pkey" PRIMARY KEY (id);


--
-- Name: PersonaRelationship PersonaRelationship_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PersonaRelationship"
    ADD CONSTRAINT "PersonaRelationship_pkey" PRIMARY KEY (id);


--
-- Name: Profile Profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_pkey" PRIMARY KEY ("userId");


--
-- Name: Recommendation Recommendation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Recommendation"
    ADD CONSTRAINT "Recommendation_pkey" PRIMARY KEY (id);


--
-- Name: ReviewItem ReviewItem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReviewItem"
    ADD CONSTRAINT "ReviewItem_pkey" PRIMARY KEY (id);


--
-- Name: Review Review_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_pkey" PRIMARY KEY (id);


--
-- Name: Tag Tag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Tag"
    ADD CONSTRAINT "Tag_pkey" PRIMARY KEY (id);


--
-- Name: TermAnnotation TermAnnotation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TermAnnotation"
    ADD CONSTRAINT "TermAnnotation_pkey" PRIMARY KEY (id);


--
-- Name: TermTag TermTag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TermTag"
    ADD CONSTRAINT "TermTag_pkey" PRIMARY KEY (id);


--
-- Name: Term Term_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_pkey" PRIMARY KEY (id);


--
-- Name: UserInterest UserInterest_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserInterest"
    ADD CONSTRAINT "UserInterest_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Favorite_userId_termId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Favorite_userId_termId_key" ON public."Favorite" USING btree ("userId", "termId");


--
-- Name: GraphEdge_fromTermId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GraphEdge_fromTermId_idx" ON public."GraphEdge" USING btree ("fromTermId");


--
-- Name: GraphEdge_fromTermId_toTermId_relationship_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "GraphEdge_fromTermId_toTermId_relationship_key" ON public."GraphEdge" USING btree ("fromTermId", "toTermId", relationship);


--
-- Name: GraphEdge_relationship_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GraphEdge_relationship_idx" ON public."GraphEdge" USING btree (relationship);


--
-- Name: GraphEdge_toTermId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "GraphEdge_toTermId_idx" ON public."GraphEdge" USING btree ("toTermId");


--
-- Name: InterestAnnotation_interestId_persona_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "InterestAnnotation_interestId_persona_key" ON public."InterestAnnotation" USING btree ("interestId", persona);


--
-- Name: Interest_slug_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Interest_slug_key" ON public."Interest" USING btree (slug);


--
-- Name: OAuthState_expiresAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OAuthState_expiresAt_idx" ON public."OAuthState" USING btree ("expiresAt");


--
-- Name: OAuthState_provider_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OAuthState_provider_idx" ON public."OAuthState" USING btree (provider);


--
-- Name: OAuthState_state_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "OAuthState_state_idx" ON public."OAuthState" USING btree (state);


--
-- Name: OAuthState_state_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "OAuthState_state_key" ON public."OAuthState" USING btree (state);


--
-- Name: PersonaRelationship_userId_persona_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "PersonaRelationship_userId_persona_key" ON public."PersonaRelationship" USING btree ("userId", persona);


--
-- Name: Recommendation_userId_recommendedAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Recommendation_userId_recommendedAt_idx" ON public."Recommendation" USING btree ("userId", "recommendedAt");


--
-- Name: ReviewItem_status_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ReviewItem_status_createdAt_idx" ON public."ReviewItem" USING btree (status, "createdAt");


--
-- Name: Review_userId_termId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Review_userId_termId_idx" ON public."Review" USING btree ("userId", "termId");


--
-- Name: Tag_name_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Tag_name_key" ON public."Tag" USING btree (name);


--
-- Name: TermAnnotation_termId_persona_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TermAnnotation_termId_persona_key" ON public."TermAnnotation" USING btree ("termId", persona);


--
-- Name: TermTag_tagId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TermTag_tagId_idx" ON public."TermTag" USING btree ("tagId");


--
-- Name: TermTag_termId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TermTag_termId_idx" ON public."TermTag" USING btree ("termId");


--
-- Name: TermTag_termId_tagId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "TermTag_termId_tagId_key" ON public."TermTag" USING btree ("termId", "tagId");


--
-- Name: UserInterest_userId_interestId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserInterest_userId_interestId_key" ON public."UserInterest" USING btree ("userId", "interestId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: user_interest_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_interest_unique ON public."UserInterest" USING btree ("userId", "interestId");


--
-- Name: Favorite Favorite_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Favorite"
    ADD CONSTRAINT "Favorite_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Favorite Favorite_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Favorite"
    ADD CONSTRAINT "Favorite_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GraphEdge GraphEdge_fromTermId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GraphEdge"
    ADD CONSTRAINT "GraphEdge_fromTermId_fkey" FOREIGN KEY ("fromTermId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: GraphEdge GraphEdge_toTermId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."GraphEdge"
    ADD CONSTRAINT "GraphEdge_toTermId_fkey" FOREIGN KEY ("toTermId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: InterestAnnotation InterestAnnotation_interestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."InterestAnnotation"
    ADD CONSTRAINT "InterestAnnotation_interestId_fkey" FOREIGN KEY ("interestId") REFERENCES public."Interest"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OAuthState OAuthState_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."OAuthState"
    ADD CONSTRAINT "OAuthState_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: PersonaRelationship PersonaRelationship_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."PersonaRelationship"
    ADD CONSTRAINT "PersonaRelationship_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Profile Profile_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Profile"
    ADD CONSTRAINT "Profile_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Recommendation Recommendation_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Recommendation"
    ADD CONSTRAINT "Recommendation_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Recommendation Recommendation_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Recommendation"
    ADD CONSTRAINT "Recommendation_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ReviewItem ReviewItem_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."ReviewItem"
    ADD CONSTRAINT "ReviewItem_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Review Review_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Review Review_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TermAnnotation TermAnnotation_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TermAnnotation"
    ADD CONSTRAINT "TermAnnotation_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: TermTag TermTag_tagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TermTag"
    ADD CONSTRAINT "TermTag_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES public."Tag"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TermTag TermTag_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TermTag"
    ADD CONSTRAINT "TermTag_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Term Term_interestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_interestId_fkey" FOREIGN KEY ("interestId") REFERENCES public."Interest"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserInterest UserInterest_interestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserInterest"
    ADD CONSTRAINT "UserInterest_interestId_fkey" FOREIGN KEY ("interestId") REFERENCES public."Interest"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserInterest UserInterest_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserInterest"
    ADD CONSTRAINT "UserInterest_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict doAOB8HU63iEucrUHohRI1pbvXrxc6xynuP5NqegTyfk4WUbwalbKdAmHzOLGK2

