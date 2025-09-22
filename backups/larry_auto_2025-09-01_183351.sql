--
-- PostgreSQL database dump
--

\restrict ruZlzf4B0I3F2CPqPZQ2jUGsmc74C9D0Ge3tVhtuX5ywVyl0pZ1XF1yTVWJy0Fy

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
-- Name: ComplexityLevel; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ComplexityLevel" AS ENUM (
    'beginner',
    'intermediate',
    'advanced',
    'expert'
);


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
-- Name: ModerationStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."ModerationStatus" AS ENUM (
    'pending',
    'approved',
    'rejected',
    'flagged'
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


--
-- Name: TopicStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TopicStatus" AS ENUM (
    'processing',
    'completed',
    'failed',
    'cancelled'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CanonicalTopicSet; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CanonicalTopicSet" (
    id text NOT NULL,
    topic text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    "termCount" integer NOT NULL,
    "factCount" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: CustomTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CustomTopic" (
    id text NOT NULL,
    "userId" text NOT NULL,
    topic text NOT NULL,
    language text DEFAULT 'en'::text NOT NULL,
    status public."TopicStatus" DEFAULT 'processing'::public."TopicStatus" NOT NULL,
    "jobId" text,
    "estimatedReadyAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: Fact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Fact" (
    id text NOT NULL,
    "topicId" text NOT NULL,
    fact text NOT NULL,
    source text NOT NULL,
    "sourceUrl" text,
    "gptGenerated" boolean DEFAULT false NOT NULL,
    category text NOT NULL,
    "moderationStatus" public."ModerationStatus" DEFAULT 'pending'::public."ModerationStatus" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


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
    "interestId" text,
    difficulty public."Difficulty" DEFAULT 'easy'::public."Difficulty" NOT NULL,
    "isRefined" boolean DEFAULT false NOT NULL,
    "qualityMetrics" jsonb,
    "selfQualityRating" double precision,
    "userQualityRating" double precision,
    category text,
    "complexityLevel" public."ComplexityLevel" DEFAULT 'beginner'::public."ComplexityLevel" NOT NULL,
    "confidenceScore" double precision DEFAULT 0.0 NOT NULL,
    "gptGenerated" boolean DEFAULT false NOT NULL,
    "moderationStatus" public."ModerationStatus" DEFAULT 'pending'::public."ModerationStatus" NOT NULL,
    "readabilityScore" double precision,
    source text,
    "sourceUrl" text,
    "topicId" text,
    verified boolean DEFAULT false NOT NULL
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
-- Name: TopicGenerationMetrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."TopicGenerationMetrics" (
    id text NOT NULL,
    "userId" text NOT NULL,
    topic text NOT NULL,
    "generationTimeMs" integer NOT NULL,
    "termCount" integer NOT NULL,
    "factCount" integer NOT NULL,
    "gptUsageRate" double precision NOT NULL,
    "qualityScore" double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
-- Data for Name: CanonicalTopicSet; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CanonicalTopicSet" (id, topic, version, "termCount", "factCount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: CustomTopic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CustomTopic" (id, "userId", topic, language, status, "jobId", "estimatedReadyAt", "createdAt", "updatedAt") FROM stdin;
cmeun3znj0007mi0t7t8pphgk	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	technology	en	failed	topic-001094.e7b14fc442874931bff4e5dc13ab6cc4.2116-1756339365440	2025-08-28 00:05:45.439	2025-08-28 00:02:45.439	2025-08-28 00:28:13.994
cmeun3zna0005mi0th0s8y7zc	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	ukulele	en	failed	topic-001094.e7b14fc442874931bff4e5dc13ab6cc4.2116-1756339365432	2025-08-28 00:05:45.43	2025-08-28 00:02:45.43	2025-08-28 00:29:36.445
cmeuo3wck0016mi0tt94tx43v	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	guitar	en	completed	topic-001094.e7b14fc442874931bff4e5dc13ab6cc4.2116-1756341040774	2025-08-28 00:33:40.772	2025-08-28 00:30:40.773	2025-08-28 00:48:54.198
cmeuqwthx0001lp0to9vr51yj	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	test-dev-mode	en	completed	topic-001094.e7b14fc442874931bff4e5dc13ab6cc4.2116-1756345749335	2025-08-28 01:52:09.333	2025-08-28 01:49:09.334	2025-08-28 02:04:59.839
cmeurj0sq0036lp0tosw9ocb9	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	art-&-design	en	completed	topic-001094.e7b14fc442874931bff4e5dc13ab6cc4.2116-1756346785228	2025-08-28 02:09:25.225	2025-08-28 02:06:25.226	2025-08-28 02:14:08.64
cmeurj0sw0038lp0th2xg48n7	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	psychology	en	completed	topic-001094.e7b14fc442874931bff4e5dc13ab6cc4.2116-1756346785234	2025-08-28 02:09:25.232	2025-08-28 02:06:25.233	2025-08-28 02:19:11.743
\.


--
-- Data for Name: Fact; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Fact" (id, "topicId", fact, source, "sourceUrl", "gptGenerated", category, "moderationStatus", "createdAt") FROM stdin;
cmeuo7bf40003mi8fsszxehrt	cmeun3znj0007mi0t7t8pphgk	A test fact	test	\N	t	history	pending	2025-08-28 00:33:20.272
cmeuorc1g002rlx0tgc6jj871	cmeuo3wck0016mi0tt94tx43v	The guitar was first invented in Spain in the 15th century.	gpt	\N	t	history	pending	2025-08-28 00:48:54.196
cmeuorc1h002tlx0tw7o9e1yh	cmeuo3wck0016mi0tt94tx43v	The world's largest guitar measures 43.5 feet in length and is based in the U.S.	gpt	\N	t	background	pending	2025-08-28 00:48:54.198
cmeuorc1i002vlx0tq126hui2	cmeuo3wck0016mi0tt94tx43v	The guitar is one of the most popular instruments worldwide, used in many music genres.	gpt	\N	t	usage	pending	2025-08-28 00:48:54.198
cmeurh6ws002vlp0tpczcksks	cmeuqwthx0001lp0to9vr51yj	Test-Driven Development (TDD) encourages developers to write tests before writing the code itself.	gpt	\N	t	usage	pending	2025-08-28 02:04:59.836
cmeurh6wt002xlp0thyy5f9zw	cmeuqwthx0001lp0to9vr51yj	The term 'bug' in software development was popularized by Grace Hopper who found a moth causing issues in a computer.	gpt	\N	t	history	pending	2025-08-28 02:04:59.837
cmeurh6wu002zlp0t8m8ontch	cmeuqwthx0001lp0to9vr51yj	Continuous Integration and Continuous Delivery (CI/CD) practices aim to automate the software delivery process.	gpt	\N	t	trends	pending	2025-08-28 02:04:59.838
cmeursyda005ylp0tnp2rd7hv	cmeurj0sq0036lp0tosw9ocb9	The term 'avant-garde' was originally used in the military to refer to the front line of an advancing army.	gpt	\N	t	history	pending	2025-08-28 02:14:08.638
cmeursydb0060lp0ttw8iwn51	cmeurj0sq0036lp0tosw9ocb9	The concept of 'wabi-sabi' in Japanese aesthetics represents a world view centered on the acceptance of transience and imperfection.	gpt	\N	t	cultural	pending	2025-08-28 02:14:08.639
cmeursydb0062lp0tendmbjii	cmeurj0sq0036lp0tosw9ocb9	The 'zero brush' in digital art refers to a brush with no hardness, meaning it has very soft edges.	gpt	\N	t	usage	pending	2025-08-28 02:14:08.64
cmeurzg8p008tlp0tklmh0yrq	cmeurj0sw0038lp0th2xg48n7	Freud's theory of psychoanalysis was a major advancement in psychology.	gpt	\N	t	history	pending	2025-08-28 02:19:11.737
cmeurzg8s008vlp0t19zqzbzp	cmeurj0sw0038lp0th2xg48n7	Stanley Milgram's experiment was a controversial study on obedience to authority.	gpt	\N	t	history	pending	2025-08-28 02:19:11.741
cmeurzg8u008xlp0tj9aosqq4	cmeurj0sw0038lp0th2xg48n7	Cognitive Behavioral Therapy is one of the most widely used psychotherapy techniques today.	gpt	\N	t	trends	pending	2025-08-28 02:19:11.742
\.


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
cmerwnm8l001n1hg8rkepr3dl	magic	Magic	Custom interest: Magic	en	2025-08-26 02:06:39.189	custom
cmerwnm8r001o1hg86mnbmete	love	Love	Custom interest: Love	en	2025-08-26 02:06:39.195	custom
cmerxb2hg002h1hg8eiek0fiw	art-&-design	Art-&-design	Generated vocabulary for art-&-design	en	2025-08-26 02:24:53.333	\N
cmeummagj006i1hg8kosaqq7b	ukulele	Ukulele	Custom interest: Ukulele	en	2025-08-27 23:48:59.635	custom
cmeuo3w8q000ymi0ttn56p910	guitar	Guitar	Custom interest: Guitar	en	2025-08-28 00:30:40.634	custom
cmeup8f1q0000k30ta0obnuor	guitair	Guitair	Custom interest: Guitair	en	2025-08-28 01:02:11.247	custom
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
001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	appleuser	free	daily	09:00	America/Los_Angeles	2025-08-27 16:00:00	\N
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

COPY public."Term" (id, term, definition, examples, "similar", "interestId", difficulty, "isRefined", "qualityMetrics", "selfQualityRating", "userQualityRating", category, "complexityLevel", "confidenceScore", "gptGenerated", "moderationStatus", "readabilityScore", source, "sourceUrl", "topicId", verified) FROM stdin;
cmert956z000f1hg8u846raub	Business"	Business"	["...an business program\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1...", "...an business program\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1..."]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmert9572000h1hg87xg7t6ig	song),	song),	["...\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1980\\nThe Business...", "...\\nThe Business (TV series)\\n\\"The Business\\" (Madness song), the B-side to \\"Baggy Trousers\\", 1980\\nThe Business..."]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmert956w000d1hg8yha84vmt	Corporations	distinct from sole proprietors and partnerships	["Corporations are distinct from sole proprietors and partnerships", "Corporations are separate and unique legal entities from their shareholders; as such they provide limited liability for their owners and members"]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmert956b00091hg854d3cy6l	business	business	["A business entity is not necessarily separate from the owner...", "A business entity is not necessarily separate from the owner..."]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmert956k000b1hg8cwhnyhie	Business	the practice of making one's living or making money by producing or buying and selling products (suc...	["Business is the practice of making one's living or making money by producing or buying and selling products (such as goods and services", "The Business may refer to:\\n\\nThe Business (magazine), a British weekly magazine\\nThe Business (band), an English punk rock/Oi"]	[]	cmersivf300021hwrerbjqo3y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeruh04u001k1hg8we48f8t1	exercise	exercise	["Many people choose to exercise outdoors where they can congregate in groups, socialize, and improve well-being as well as mental health", "In terms of health benefits, usually, 150 minutes of moderate-intensity exercise per week is recommended for reducing the risk of health problems"]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeruh04y001m1hg8n1stwest	fitness	a state of health and well-being and, more specifically, the ability to perform aspects of sports, o...	["Physical fitness is a state of health and well-being and, more spe...", "Physical fitness is generally achieved through proper nutrition, m..."]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeruh04s001i1hg8r6fk2uoz	health	health	["Exercise or working out is physical activity that enhances or maintains fitness and overall health", "Many people choose to exercise outdoors where they can congregate in groups, socialize, and improve well-being as well as mental health"]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeruh04g001e1hg8erds8kj0	Microsoft	Microsoft	["MSN is a web portal and related collection of Internet services and apps provided by Microsoft", "...t curated from hundreds of different sources that Microsoft has partnered with"]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeruh04k001g1hg8oddiqk32	Internet	Internet	["MSN is a web portal and related collection of Internet services and apps provided by Microsoft", "... called The Microsoft Network; it later became an Internet service provider named MSN Dial-Up Internet Acces..."]	[]	cmeruh04a001c1hg8zbnkgw0y	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerwr3lz00261hg8k4uj7z4b	cooking	cooking	["Types of cooking also depend on the skill levels and training of the cooks", "The term \\"culinary arts\\" usually refers to cooking that is primarily focused on the aesthetic beauty of the presentation and taste of the food"]	[]	cmersivfa00051hwrgue8tsg3	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerwr3ma002c1hg8chnerwyt	induction	induction	["Induction cooking is a cooking process using direct electrical induction heating of cookware, rather than relying on flames or heating elements", "Pots or pans with suitable bases are placed on an induction electric stove (also induction hob or induction c..."]	[]	cmersivfa00051hwrgue8tsg3	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerwr3m8002a1hg8dlks1bf0	techniques	techniques	["Cooking techniques and ingredients vary widely, from grilling food o...", "Cooking techniques and ingredients vary widely, from grilling food o..."]	[]	cmersivfa00051hwrgue8tsg3	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerwr3mc002e1hg8jfnrfp4h	Cooking	Cooking	["Cooking techniques and ingredients vary widely, from grilling food over an open fire, to using electric stoves, to baking in various types of ovens, to boiling  and blanching in water, reflecting local conditions, techniques and traditions", "Cooking is an aspect of all human societies and a cultural universal"]	[]	cmersivfa00051hwrgue8tsg3	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerwr3m500281hg8ts4d7tjc	Induction	Induction	["Induction cooking is a cooking process using direct electrical induction heating of cookware, rather than relying on flames or heating elements", "Induction cooking allows high power and very rapid increases in temperature to be achieved: changes in heat settings are instantaneous"]	[]	cmersivfa00051hwrgue8tsg3	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxb2i0002r1hg8rqn2c3t5	visual	visual	["...discipline and applied art that involves creating visual communications intended to transmit specific mess...", "They work on the interpretation, ordering, and presentation of visual messages"]	[]	cmerxb2hg002h1hg8eiek0fiw	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxb2hn002j1hg8730n6u01	design	a profession, academic discipline and applied art that involves creating visual communications inten...	["Graphic design is a profession, academic discipline and applied ...", "Graphic design is an interdisciplinary branch of design and of the fine arts"]	[]	cmerxb2hg002h1hg8eiek0fiw	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxb2hs002l1hg8optm928b	graphic	graphic	["The role of the graphic designer in the communication process is that of the encoder or interpreter of the message", "Usually, graphic design uses the aesthetics of typography and the ..."]	[]	cmerxb2hg002h1hg8eiek0fiw	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxb2hv002n1hg8knamn8l5	applied	applied	["...c design is a profession, academic discipline and applied art that involves creating visual communications ...", "For example, it can be applied in advertising strategies, or it can also be applied in the aviation world or space exploration"]	[]	cmerxb2hg002h1hg8eiek0fiw	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxb2hx002p1hg8qwdm5nrd	artists	visual artists involved from the conception of the game who make rough sketches of the characters, s...	["Video game artists are visual artists involved from the conception of the game who make rough sketches of the characters, setting, objects, etc", "Video game artists are visual artists involved from the conception of the game who make rough sketches of the characters, setting, objects, etc"]	[]	cmerxb2hg002h1hg8eiek0fiw	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxnysb00351hg8uw724coe	Modern science	typically divided into two – or three – major branches: the natural sciences, which study the physic...	["Modern science is typically divided into two – or three – major branches: the natural sciences, which study the physical world, and the social sciences, which study individuals and societies"]	[]	cmersivf100011hwr608lmd7m	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxnys700331hg8d1bpclbr	video game	video game	["Game Science (Chinese: 游戏科学; pinyin: Yóuxì Kēxué) is a Chinese video game development and publishing company founded by Feng Ji and Yang Qi in", "It is best known for developing the video game Black Myth: Wukong"]	[]	cmersivf100011hwr608lmd7m	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxnyrz002z1hg8nlrjgekc	Science	a systematic discipline that builds and organises knowledge in the form of testable hypotheses and p...	["Science is a systematic discipline that builds and organises knowledge in the form of testable hypotheses and predictions about the universe", "Science is a systematic method for obtaining knowledge that is natural, measurable or consisting of systematic principles, generally through testable explanations and predictions"]	[]	cmersivf100011hwr608lmd7m	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxnyru002x1hg8b9w6zsd8	science	typically divided into two – or three – major branches: the natural sciences, which study the physic...	["Modern science is typically divided into two – or three – major ...", "While referred to as the formal sciences, the study of logic, mathematics, and theoretica..."]	[]	cmersivf100011hwr608lmd7m	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerxnys300311hg8pda6x3fd	systematic	systematic	["Science is a systematic method for obtaining knowledge that is natural, m...", "Science is a systematic method for obtaining knowledge that is natural, m..."]	[]	cmersivf100011hwr608lmd7m	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerymofd003d1hg8eku3gooa	betting	in some cases severely regulated, and in others integral to the sport	["Sport betting is in some cases severely regulated, and in others integral to the sport", "Sports betting is the activity of predicting sports results and placing a wager on the outcome"]	[]	cmersivfd00071hwrvlwi3hse	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerymof100391hg8fbaf6mb4	sports	sports	["Many sports leagues make an annual champion by arranging games in a regular sports season, followed in some cases by playoffs", "Many sports leagues make an annual champion by arranging games in a regular sports season, followed in some cases by playoffs"]	[]	cmersivfd00071hwrvlwi3hse	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeuorc0d000dlx0tb40yh46h	riffs	Definition for riffs	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0f000flx0ty6rxhz76	tabs	Definition for tabs	[]	[]	\N	easy	f	\N	\N	\N	jargon	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0g000hlx0tdpwnduyh	licks	Definition for licks	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0h000jlx0trdna6ftt	shredding	Definition for shredding	[]	[]	\N	hard	f	\N	\N	\N	slang	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0j000llx0tluwr07fo	fretting	Definition for fretting	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0k000nlx0t311163g2	bending	Definition for bending	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0l000plx0tvgq2e3lv	palm muting	Definition for palm muting	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmerymofi003h1hg8u1zj8ap3	number	number	["The number of participants in a particular sport can vary from hundreds of people to a single individual", "However, a number of competitive, but non-physical, activities claim recognition as mind sports"]	[]	cmersivfd00071hwrvlwi3hse	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerymoff003f1hg8ne4kogz2	Sports	Sports	["beIN Sports ( BEE-in) is a Qatari multinational network of sports channels owned and operated by the media group beIN", "beIN Sports is the dominant television sports channel in the MENA region"]	[]	cmersivfd00071hwrvlwi3hse	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmerymof9003b1hg86hd1jzj6	physical	physical	["Sport is a physical activity or game, often competitive and organized, that maintains or improves physical ability and skills", "Sport is a physical activity or game, often competitive and organized, that maintains or improves physical ability and skills"]	[]	cmersivfd00071hwrvlwi3hse	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmet4t7zf004p1hg8h7bijaqe	history,	history,	["Some focus on specific time periods, such as ancient history, while others concentrate on particular geographic regions, such as the history of Africa", "Thematic categorizations include political history, military history, social history, and economic history"]	[]	cmersivfl000a1hwr2o1tul0t	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmet4t7zt004x1hg8mk2cyq79	sources	sources	["Historical research relies on primary and secondary sources to reconstruct past events and validate interpretations", "Historians strive to integrate the perspectives of several sources to develop a coherent narrative"]	[]	cmersivfl000a1hwr2o1tul0t	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmet4t7zk004r1hg87ne5hzvw	history	history	["Some theorists categorize history as a social science, while others see it as part of the humanities or consider it a hybrid discipline", "In a more general sense, the term history refers not to an academic field but to the past i..."]	[]	cmersivfl000a1hwr2o1tul0t	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmet4t7zr004v1hg834yufzid	academic	academic	["As an academic discipline, it analyses and interprets evidence to construct narratives about what happened and explain why it happened", "... general sense, the term history refers not to an academic field but to the past itself, times in the past, ..."]	[]	cmersivfl000a1hwr2o1tul0t	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmet4t7zo004t1hg8vzp9neuv	History	the systematic study of the past, focusing primarily on the human past	["History is the systematic study of the past, focusing primarily on the human past", "History is a broad discipline encompassing many branches"]	[]	cmersivfl000a1hwr2o1tul0t	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeummbfr006u1hg8gbxo3j3b	liabilities	liabilities	["In finance, equity is an ownership interest in property that may be subject to debts or other liabilities", "Equity is measured for accounting purposes by subtracting liabilities from the value of the assets owned"]	[]	cmersivfo000c1hwrag8mgd81	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeummbfk006q1hg8oakatb8y	financial	financial	["Based on the scope of financial activities in financial systems, the discipline can be divided into personal, corporate, and public finance", "Based on the scope of financial activities in financial systems, the discipline can be divided into personal, corporate, and public finance"]	[]	cmersivfo000c1hwrag8mgd81	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeummbfo006s1hg83dte2mmz	equity	an ownership interest in property that may be subject to debts or other liabilities	["In finance, equity is an ownership interest in property that may be subject to debts or other liabilities", "For example, if someone owns a car worth $24,000 and owes $10,000 on the loan used to buy the car, the difference of $14,000 is equity"]	[]	cmersivfo000c1hwrag8mgd81	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeummbfe006o1hg8gpsrd41f	finance	finance	["Based on the scope of financial activities in financial systems, the discipline can be divided into personal, corporate, and public finance", "Due to its wide scope, a broad range of subfields exists within finance"]	[]	cmersivfo000c1hwrag8mgd81	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeummbfu006w1hg8dd61zhd5	fields	multidisciplinary, such as mathematical finance, financial law, financial economics, financial engin...	["Some fields are multidisciplinary, such as mathematical finance, financial law, financial economics, financial engineering and financial technology", "These fields are the foundation of business and accounting"]	[]	cmersivfo000c1hwrag8mgd81	medium	t	{"clarity": 5, "relevance": 5, "exampleQuality": 5, "educationalValue": 5}	5	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeun40pm000bmi0tux2taw2z	information	In the context of technology, 'information' refers to data processed or stored by a computer, this can be in the form of text, images, audio, video, etc.	["In the digital age, countless bytes of information are generated every second, from text messages to online transactions.", "Cybersecurity measures protect sensitive information from unauthorized access or damage.", "Information retrieval systems, like search engines, find and present information relevant to users' queries."]	["data", "knowledge", "facts", "details", "intelligence"]	cmersives00001hwrrjmq0vig	easy	t	{"clarity": 9, "relevance": 9, "exampleQuality": 9, "educationalValue": 9}	9	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeun40pf0009mi0tia0n9kp7	technology	Technology refers to the collection of techniques, skills, methods, and processes used in the production of goods or services, or in the accomplishment of objectives such as scientific investigation.	["The advent of digital technology has revolutionized communication, enabling instant interaction between people from around the globe.", "Technology plays a crucial role in the medical field, with advancements like MRI machines and robotic surgery improving diagnostics and treatment.", "The invention of wheel is an early example of human's use of technology to ease physical labor and transportation."]	["innovation", "technique", "machinery", "devices", "informatics"]	cmersives00001hwrrjmq0vig	easy	t	{"clarity": 9, "relevance": 9, "exampleQuality": 9, "educationalValue": 9}	9	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeun40pu000fmi0tpxtswk22	Technology	Technology is the systematic application of scientific knowledge to create tools, systems, or methods for solving problems or accomplishing tasks.	["The invention of the wheel is one of the earliest examples of technology, simplifying transportation and reshaping societies.", "Modern technology, like smartphones and the internet, has transformed how we communicate, learn, and work.", "In medical field, technology has greatly improved the ability to diagnose and treat diseases, improving overall health and lifespan."]	["innovation", "machinery", "electronics", "informatics", "techniques"]	cmersives00001hwrrjmq0vig	easy	t	{"clarity": 9, "relevance": 9, "exampleQuality": 9, "educationalValue": 9}	9	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeun40pq000dmi0tkjse7spo	computer	A computer is a programmable electronic device designed to accept data, perform prescribed mathematical and logical operations, and display the results at high speed.	["The computer is a vital tool in many different jobs and activities, for example in the field of digital graphics where it is used for creating and editing artwork.", "In a scientific research, computers are used to analyze complex data and generate results.", "Learning computer programming can help develop problem-solving skills."]	["PC", "laptop", "mainframe", "supercomputer", "workstation"]	cmersives00001hwrrjmq0vig	easy	t	{"clarity": 9, "relevance": 9, "exampleQuality": 9, "educationalValue": 9}	9	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeun40py000hmi0ti26f193r	systems	In technology, 'systems' refer to interconnected and interacting components that work together to accomplish a specific task or function, such as computers, telecommunication devices, and data storage units.	["In a hospital, various systems such as patient management, medication dispensing, and medical record-keeping work together to provide efficient healthcare services.", "The telecommunication systems are crucial for facilitating global communications, enabling instant transmission of voice, text, and video across vast distances.", "Advanced computer systems are at the heart of modern financial transactions, powering everything from online banking to real-time stock trading."]	["networks", "infrastructures", "configurations", "frameworks", "complexes"]	cmersives00001hwrrjmq0vig	medium	t	{"clarity": 9, "relevance": 9, "exampleQuality": 9, "educationalValue": 9}	9	\N	\N	beginner	0	f	pending	\N	\N	\N	\N	f
cmeuo7bf10001mi8ftn676mmy	test-term	A test definition	["Example 1", "Example 2"]	["similar1", "similar2"]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	test	\N	cmeun3znj0007mi0t7t8pphgk	f
cmeuob6ww0001mi9urcvrsqxr	algorithm	An algorithm is a set of instructions for solving a problem or completing a task.	["Example 1", "Example 2"]	["similar1", "similar2"]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeun3znj0007mi0t7t8pphgk	f
cmeuorc020001lx0tz8k3nudt	acoustic guitar	Definition for acoustic guitar	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc050003lx0t2cwyzct4	electric guitar	Definition for electric guitar	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc070005lx0txwnemfkc	bass guitar	Definition for bass guitar	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc090007lx0tnk5e24x4	capo	Definition for capo	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0a0009lx0tcgeb3q7a	plectrum	Definition for plectrum	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0c000blx0tjedlxblb	chords	Definition for chords	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0m000rlx0ty2tr34cw	tapping	Definition for tapping	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0m000tlx0tbcxwfh1y	standard tuning	Definition for standard tuning	[]	[]	\N	easy	f	\N	\N	\N	jargon	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0n000vlx0txaom825p	drop d tuning	Definition for drop d tuning	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0o000xlx0t57f3wdc7	bar chords	Definition for bar chords	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0p000zlx0tkj3sfgtj	open chords	Definition for open chords	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0p0011lx0teaeqzhe1	blues scale	Definition for blues scale	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0q0013lx0td5maxddf	pentatonic scale	Definition for pentatonic scale	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0r0015lx0t4xha0vgg	fingerstyle	Definition for fingerstyle	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0r0017lx0tbemgsabm	flatpicking	Definition for flatpicking	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0s0019lx0t8ruijcyh	harmonics	Definition for harmonics	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0t001blx0tkv17qlfc	hammer-on	Definition for hammer-on	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0u001dlx0tftmrkges	pull-off	Definition for pull-off	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0v001flx0tgdry29x5	slide	Definition for slide	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0w001hlx0tj8ulfxx5	bottleneck	Definition for bottleneck	[]	[]	\N	hard	f	\N	\N	\N	jargon	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0x001jlx0tnvsyc9yu	whammy bar	Definition for whammy bar	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc0z001llx0tl7atia24	distortion	Definition for distortion	[]	[]	\N	easy	f	\N	\N	\N	jargon	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc10001nlx0tmzsnx762	overdrive	Definition for overdrive	[]	[]	\N	easy	f	\N	\N	\N	jargon	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc11001plx0tjz59uq34	reverb	Definition for reverb	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc11001rlx0tnnux0vtm	delay	Definition for delay	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc12001tlx0tg7n2geh1	chorus	Definition for chorus	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc13001vlx0tph9995kj	phaser	Definition for phaser	[]	[]	\N	hard	f	\N	\N	\N	jargon	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc13001xlx0t4o0a6ymo	flanger	Definition for flanger	[]	[]	\N	hard	f	\N	\N	\N	jargon	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc14001zlx0t4c8bsitu	wah-wah	Definition for wah-wah	[]	[]	\N	hard	f	\N	\N	\N	jargon	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc150021lx0tvgquspt7	vibrato	Definition for vibrato	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc160023lx0tntr73mh2	tremolo	Definition for tremolo	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc160025lx0tlobuo0r5	pickup	Definition for pickup	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc170027lx0t61s108pm	amp	Definition for amp	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc180029lx0trn3yce59	gig	Definition for gig	[]	[]	\N	easy	f	\N	\N	\N	slang	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc18002blx0t7wh2klbt	jamming	Definition for jamming	[]	[]	\N	easy	f	\N	\N	\N	slang	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc19002dlx0tpnn8cfe5	rhythm guitar	Definition for rhythm guitar	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc1a002flx0tn32qxn9h	lead guitar	Definition for lead guitar	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc1b002hlx0t94n3zkrs	twelve-bar blues	Definition for twelve-bar blues	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc1b002jlx0trc5ws9mj	truss rod	Definition for truss rod	[]	[]	\N	hard	f	\N	\N	\N	jargon	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc1d002llx0t04soy6q1	caged system	Definition for caged system	[]	[]	\N	hard	f	\N	\N	\N	jargon	advanced	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc1e002nlx0t8fe1052u	bridge	Definition for bridge	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeuorc1f002plx0tbtojt040	nut	Definition for nut	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuo3wck0016mi0tt94tx43v	f
cmeurh6v40003lp0tr8ja0mkw	test environment	Definition for test environment	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6v80005lp0to1tvme44	bug	Definition for bug	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6va0007lp0t18ft2usn	debugging	Definition for debugging	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vd0009lp0tijplanwm	unit testing	Definition for unit testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6ve000blp0tew7cmf7b	integration testing	Definition for integration testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vg000dlp0tf5hsrn87	regression testing	Definition for regression testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vh000flp0tm2vn3wsk	alpha testing	Definition for alpha testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vj000hlp0t6blghv5x	beta testing	Definition for beta testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vl000jlp0t8241y8rh	smoke testing	Definition for smoke testing	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vm000llp0tb5s94xdx	black box testing	Definition for black box testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vo000nlp0t8ymqfsmd	white box testing	Definition for white box testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vp000plp0tv7j2w1xa	test case	Definition for test case	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vr000rlp0tj3ze02ne	sandbox	Definition for sandbox	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vs000tlp0tds456b9j	test harness	Definition for test harness	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vt000vlp0t5qnv3e04	mock object	Definition for mock object	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vu000xlp0tj2gt2d1d	end-to-end testing	Definition for end-to-end testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vv000zlp0toggzrb6b	load testing	Definition for load testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vw0011lp0tptocstjj	stress testing	Definition for stress testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vx0013lp0tjgd3uvy3	performance testing	Definition for performance testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6vz0015lp0t9gl3x9qy	functional testing	Definition for functional testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w00017lp0tvthkyk9j	test runner	Definition for test runner	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w00019lp0tg0niafzw	test suite	Definition for test suite	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w1001blp0tcp1d8a0e	production environment	Definition for production environment	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w2001dlp0ty7ol7lia	failover	Definition for failover	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w3001flp0t24a28kvw	code review	Definition for code review	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w4001hlp0t7x8ahtcm	automated testing	Definition for automated testing	[]	[]	\N	medium	f	\N	\N	\N	strategy	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w5001jlp0tlyds2kiy	devops	Definition for devops	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w6001llp0trhyn9fj5	continuous integration	Definition for continuous integration	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w8001nlp0t2i1oc790	continuous delivery	Definition for continuous delivery	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w8001plp0tv57u9pyx	continuous deployment	Definition for continuous deployment	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6w9001rlp0tjb8g2cjc	test-driven development	Definition for test-driven development	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wa001tlp0te1lssmrd	behavior-driven development	Definition for behavior-driven development	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wb001vlp0t1f5v3z66	acceptance criteria	Definition for acceptance criteria	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wc001xlp0trv3xoi3s	version control	Definition for version control	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wd001zlp0tymzhuxdt	repository	Definition for repository	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6we0021lp0tftql7sxt	build	Definition for build	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wf0023lp0taa1a2qky	release	Definition for release	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wg0025lp0tgtp3sre8	rollback	Definition for rollback	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wh0027lp0t0l11rt84	hotfix	Definition for hotfix	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wi0029lp0t5nuz0pby	staging environment	Definition for staging environment	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wj002blp0txv6una5d	deployment pipeline	Definition for deployment pipeline	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wj002dlp0toksfeudg	feature toggle	Definition for feature toggle	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wk002flp0tzdkmx1ry	a/b testing	Definition for a/b testing	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wl002hlp0t187f1iuf	canary release	Definition for canary release	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wm002jlp0tnncqxn4a	blue-green deployment	Definition for blue-green deployment	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wn002llp0tqb1ns2tr	chaos engineering	Definition for chaos engineering	[]	[]	\N	hard	f	\N	\N	\N	strategy	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wo002nlp0txkgrsw46	code coverage	Definition for code coverage	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wp002plp0tmnvyjma9	mutation testing	Definition for mutation testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wq002rlp0tgwfqqrer	fuzz testing	Definition for fuzz testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeurh6wr002tlp0t6rurkmyl	penetration testing	Definition for penetration testing	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeuqwthx0001lp0to9vr51yj	f
cmeursybx003alp0t2r3fskhm	aesthetics	Definition for aesthetics	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyc2003clp0tn57uskru	analogous colors	Definition for analogous colors	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyc3003elp0t5lfmh0ji	asymmetry	Definition for asymmetry	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyc5003glp0tbcnvdekm	avant-garde	Definition for avant-garde	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyc7003ilp0ttfvqrf3r	chiaroscuro	Definition for chiaroscuro	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyc8003klp0tt9ld8xko	complementary colors	Definition for complementary colors	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyc9003mlp0tpsao2wia	conceptual art	Definition for conceptual art	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyca003olp0t8qm52vm6	contrast	Definition for contrast	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycb003qlp0tts0a8c1x	decoupage	Definition for decoupage	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycc003slp0tvvrgln9e	diptych	Definition for diptych	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycd003ulp0tlew9i852	ergonomics	Definition for ergonomics	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyce003wlp0tqhrdfrh5	fauvism	Definition for fauvism	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycf003ylp0twnbt82bn	gouache	Definition for gouache	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycg0040lp0tnd5kopvc	hue	Definition for hue	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursych0042lp0txsd3gy2h	impasto	Definition for impasto	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyci0044lp0tk7mgo7co	juxtaposition	Definition for juxtaposition	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycj0046lp0t11lsgnpo	kinetic art	Definition for kinetic art	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyck0048lp0t0btqq145	line weight	Definition for line weight	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycl004alp0tzzi9mdfi	medium	Definition for medium	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycm004clp0tcmf4hxml	negative space	Definition for negative space	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycn004elp0tshwi0b9b	opacity	Definition for opacity	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyco004glp0toizq3jtz	pointillism	Definition for pointillism	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyco004ilp0tzb7pfre9	quadratura	Definition for quadratura	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycp004klp0tuyx2w55i	raster graphics	Definition for raster graphics	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycq004mlp0txzesoy9f	saturation	Definition for saturation	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycr004olp0thtln372l	triptych	Definition for triptych	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyct004qlp0tsu81shn0	underpainting	Definition for underpainting	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyct004slp0t8a62lln4	vignette	Definition for vignette	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycu004ulp0t10568ymx	wash	Definition for wash	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycv004wlp0t8dp17u35	xerography	Definition for xerography	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycw004ylp0tw4fs6yw1	yarn bombing	Definition for yarn bombing	[]	[]	\N	medium	f	\N	\N	\N	slang	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycx0050lp0t3dxn80j2	zine	Definition for zine	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycy0052lp0tvxsaud29	sgraffito	Definition for sgraffito	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycy0054lp0t1nwoudj5	mosaic	Definition for mosaic	[]	[]	\N	easy	f	\N	\N	\N	technique	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursycz0056lp0t8ilxmao4	plein air	Definition for plein air	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd00058lp0tgom44j94	silkscreen	Definition for silkscreen	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd1005alp0tcod5t6ew	stippling	Definition for stippling	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd2005clp0tzsfxnbf0	intaglio	Definition for intaglio	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd3005elp0tlrokfzmn	cubism	Definition for cubism	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd3005glp0t5obvvsbg	dadaism	Definition for dadaism	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd4005ilp0thes6co1j	rococo	Definition for rococo	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd5005klp0twethwz16	surrealism	Definition for surrealism	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd6005mlp0t48iauip2	tessellation	Definition for tessellation	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd6005olp0tsabgtqkq	vanishing point	Definition for vanishing point	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd7005qlp0t5knblukt	wabi-sabi	Definition for wabi-sabi	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd8005slp0tifol82iw	x-height	Definition for x-height	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd9005ulp0tx0rgeizc	yardage	Definition for yardage	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeursyd9005wlp0tuby4xr3y	zero brush	Definition for zero brush	[]	[]	\N	medium	f	\N	\N	\N	jargon	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sq0036lp0tosw9ocb9	f
cmeurzg6r0065lp0t4zi1gywf	cognitive dissonance	Definition for cognitive dissonance	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg6u0067lp0t4kre8zco	freudian slip	Definition for freudian slip	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg6w0069lp0temlvovk8	behaviorism	Definition for behaviorism	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg6y006blp0ton7kamln	psychoanalysis	Definition for psychoanalysis	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg6z006dlp0tfwdow0cn	self-actualization	Definition for self-actualization	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg79006flp0th78cygpr	operant conditioning	Definition for operant conditioning	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7c006hlp0tzyx4ljiz	psychometrics	Definition for psychometrics	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7g006jlp0tj7xbu9kh	neuropsychology	Definition for neuropsychology	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7h006llp0tmgp6wzy1	thematic apperception test	Definition for thematic apperception test	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7i006nlp0tvdzsqher	rorschach test	Definition for rorschach test	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7j006plp0tlpi0acu8	flooding	Definition for flooding	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7k006rlp0tzyjvijc5	systematic desensitization	Definition for systematic desensitization	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7l006tlp0tzl76li15	repression	Definition for repression	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7m006vlp0t237bxonv	regression	Definition for regression	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7n006xlp0t98kkc808	transference	Definition for transference	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7p006zlp0tiyd0kzi9	countertransference	Definition for countertransference	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7q0071lp0trgjhskdh	hawthorne effect	Definition for hawthorne effect	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7r0073lp0t8qp3s0uw	milgram experiment	Definition for milgram experiment	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7s0075lp0t5xikr2rb	stanford prison experiment	Definition for stanford prison experiment	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7s0077lp0tvb2z7cak	bystander effect	Definition for bystander effect	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7t0079lp0tf4tgzz16	confirmation bias	Definition for confirmation bias	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7v007blp0tfwyv0x81	hindsight bias	Definition for hindsight bias	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7v007dlp0t0v0liv2i	pavlovian conditioning	Definition for pavlovian conditioning	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7w007flp0tc1amezmk	maslow's hierarchy of needs	Definition for maslow's hierarchy of needs	[]	[]	\N	easy	f	\N	\N	\N	vocab	beginner	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7x007hlp0tglrd67iy	erikson's stages of development	Definition for erikson's stages of development	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7x007jlp0t0awqhbiz	mmpi	Definition for mmpi	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7y007llp0t0n4qb89q	cognitive behavioral therapy	Definition for cognitive behavioral therapy	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7z007nlp0t4kjcpei2	psychoanalytic therapy	Definition for psychoanalytic therapy	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg7z007plp0t5znxnlw0	humanistic therapy	Definition for humanistic therapy	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg80007rlp0txi4vscs7	hypnosis	Definition for hypnosis	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg81007tlp0ttt1cupk5	electroconvulsive therapy	Definition for electroconvulsive therapy	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg82007vlp0tpgpvegxg	placebo effect	Definition for placebo effect	[]	[]	\N	medium	f	\N	\N	\N	vocab	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg83007xlp0t0q1fqay3	double blind study	Definition for double blind study	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg84007zlp0tb8kjvgha	cross-sectional study	Definition for cross-sectional study	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg850081lp0tvfv0ngco	longitudinal study	Definition for longitudinal study	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg860083lp0trfm1in7w	gestalt therapy	Definition for gestalt therapy	[]	[]	\N	medium	f	\N	\N	\N	technique	intermediate	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg870085lp0t0901l9r5	dialectical behavior therapy	Definition for dialectical behavior therapy	[]	[]	\N	hard	f	\N	\N	\N	technique	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg880087lp0tpvrzfh69	reactive attachment disorder	Definition for reactive attachment disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg880089lp0tlb8eeldy	oppositional defiant disorder	Definition for oppositional defiant disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg89008blp0tevpt2kj2	antisocial personality disorder	Definition for antisocial personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8b008dlp0t7tpye4tg	borderline personality disorder	Definition for borderline personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8c008flp0tctmkkhbm	narcissistic personality disorder	Definition for narcissistic personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8e008hlp0tlym4smrv	histrionic personality disorder	Definition for histrionic personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8f008jlp0t643zqu23	avoidant personality disorder	Definition for avoidant personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8g008llp0tjopo03h0	dependent personality disorder	Definition for dependent personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8i008nlp0tim3l4kz4	obsessive-compulsive personality disorder	Definition for obsessive-compulsive personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8k008plp0tlelecg03	schizoid personality disorder	Definition for schizoid personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
cmeurzg8n008rlp0t3w6d0fr9	schizotypal personality disorder	Definition for schizotypal personality disorder	[]	[]	\N	hard	f	\N	\N	\N	vocab	advanced	0.8	t	pending	\N	gpt	\N	cmeurj0sw0038lp0th2xg48n7	f
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
-- Data for Name: TopicGenerationMetrics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."TopicGenerationMetrics" (id, "userId", topic, "generationTimeMs", "termCount", "factCount", "gptUsageRate", "qualityScore", "createdAt") FROM stdin;
cmeuorc2x002wlx0td8ux44f6	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	guitar	441873	49	3	0.04081632653061224	0.8561224489795927	2025-08-28 00:48:54.249
cmeurh6yc0030lp0t2qj5djxv	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	test-dev-mode	950501	50	3	0.86	0.8989999999999994	2025-08-28 02:04:59.892
cmeursydm0063lp0t7ly70r4o	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	art-&-design	463411	48	3	0.04166666666666666	0.8479166666666673	2025-08-28 02:14:08.642
cmeurzg98008ylp0t7idfxrjn	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	psychology	764449	48	3	0.02083333333333333	0.8531250000000007	2025-08-28 02:19:11.745
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
cmes01wfv003l1hg8mmim0t3k	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmeruh04a001c1hg8zbnkgw0y	50	t	2025-08-26 03:41:44.442
cmert9va9000n1hg8n0w8bf84	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfl000a1hwr2o1tul0t	50	t	2025-08-26 00:31:58.881
cmeswcwo2003p1hg8wd0cxfng	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmerxb2hg002h1hg8eiek0fiw	0	f	2025-08-26 18:46:05.665
cmerugz1200191hg8zlohnu3h	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfm000b1hwrakbsp0bl	0	f	2025-08-26 01:05:29.942
cmert9vam000v1hg8kpbusg67	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfo000c1hwrag8mgd81	0	f	2025-08-26 00:31:58.894
cmert945l00051hg80ck1at6g	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf300021hwrerbjqo3y	0	f	2025-08-26 00:31:23.721
cmert945p00071hg86v3twq6l	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfs000e1hwrvlaapv3x	0	f	2025-08-26 00:31:23.725
cmert9vap00131hg8xxw6q9ef	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf600031hwr3ohkyu36	0	f	2025-08-26 00:31:58.897
cmert9van000x1hg8c6hyuual	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfi00091hwrfghd06tj	0	f	2025-08-26 00:31:58.895
cmert3h8s00011hg82bjrwy5n	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfg00081hwrk2gkvwsp	0	f	2025-08-26 00:27:00.747
cmert9val000t1hg8rbw5jyd0	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfa00051hwrgue8tsg3	0	f	2025-08-26 00:31:58.889
cmert3h8u00031hg8yj56zqmu	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfq000d1hwrp6xle5j9	0	f	2025-08-26 00:27:00.75
cmerwnm90001w1hg8pz8yyy4t	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmerwnm8l001n1hg8rkepr3dl	0	f	2025-08-26 02:06:39.204
cmert9vaq00151hg81wniebqu	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfb00061hwr7qh6blfm	0	f	2025-08-26 00:31:58.898
cmert9va7000j1hg87dv64aci	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf800041hwrqscv8j8n	0	f	2025-08-26 00:31:58.879
cmert9va8000l1hg8tn87ix2g	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivf100011hwr608lmd7m	0	f	2025-08-26 00:31:58.88
cmert9var00171hg8x2ef6xj3	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersivfd00071hwrvlwi3hse	0	f	2025-08-26 00:31:58.899
cmerwnm92001y1hg8hk3nyz4w	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmerwnm8r001o1hg86mnbmete	0	f	2025-08-26 02:06:39.206
cmeuo3w8x0014mi0tykzkwjxr	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmeuo3w8q000ymi0ttn56p910	0	f	2025-08-28 00:30:40.641
cmeummagx006m1hg83zdplc8k	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmeummagj006i1hg8kosaqq7b	0	f	2025-08-27 23:48:59.649
cmeup8f210008k30thqavl80t	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmeup8f1q0000k30ta0obnuor	0	f	2025-08-28 01:02:11.257
cmeun3zht0001mi0thlgt3e2p	001094.e7b14fc442874931bff4e5dc13ab6cc4.2116	cmersives00001hwrrjmq0vig	0	f	2025-08-28 00:02:45.233
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
31932b69-a9ff-478e-8e11-09fc995c3b60	98b43379b97f19b19618ca14107ec0a2b708803aa75a29be1f733a10d2cdf44d	2025-08-27 22:11:44.260341+00	20250827221144_add_custom_topic_vocabulary_system	\N	\N	2025-08-27 22:11:44.219926+00	1
\.


--
-- Name: CanonicalTopicSet CanonicalTopicSet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CanonicalTopicSet"
    ADD CONSTRAINT "CanonicalTopicSet_pkey" PRIMARY KEY (id);


--
-- Name: CustomTopic CustomTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomTopic"
    ADD CONSTRAINT "CustomTopic_pkey" PRIMARY KEY (id);


--
-- Name: Fact Fact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_pkey" PRIMARY KEY (id);


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
-- Name: TopicGenerationMetrics TopicGenerationMetrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."TopicGenerationMetrics"
    ADD CONSTRAINT "TopicGenerationMetrics_pkey" PRIMARY KEY (id);


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
-- Name: CanonicalTopicSet_topic_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CanonicalTopicSet_topic_idx" ON public."CanonicalTopicSet" USING btree (topic);


--
-- Name: CanonicalTopicSet_topic_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CanonicalTopicSet_topic_key" ON public."CanonicalTopicSet" USING btree (topic);


--
-- Name: CustomTopic_jobId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CustomTopic_jobId_idx" ON public."CustomTopic" USING btree ("jobId");


--
-- Name: CustomTopic_jobId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CustomTopic_jobId_key" ON public."CustomTopic" USING btree ("jobId");


--
-- Name: CustomTopic_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "CustomTopic_status_idx" ON public."CustomTopic" USING btree (status);


--
-- Name: CustomTopic_userId_topic_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "CustomTopic_userId_topic_key" ON public."CustomTopic" USING btree ("userId", topic);


--
-- Name: Fact_moderationStatus_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Fact_moderationStatus_idx" ON public."Fact" USING btree ("moderationStatus");


--
-- Name: Fact_topicId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Fact_topicId_idx" ON public."Fact" USING btree ("topicId");


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
-- Name: Term_confidenceScore_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Term_confidenceScore_idx" ON public."Term" USING btree ("confidenceScore");


--
-- Name: Term_gptGenerated_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Term_gptGenerated_idx" ON public."Term" USING btree ("gptGenerated");


--
-- Name: Term_moderationStatus_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Term_moderationStatus_idx" ON public."Term" USING btree ("moderationStatus");


--
-- Name: Term_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Term_source_idx" ON public."Term" USING btree (source);


--
-- Name: Term_topicId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "Term_topicId_idx" ON public."Term" USING btree ("topicId");


--
-- Name: TopicGenerationMetrics_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TopicGenerationMetrics_createdAt_idx" ON public."TopicGenerationMetrics" USING btree ("createdAt");


--
-- Name: TopicGenerationMetrics_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "TopicGenerationMetrics_userId_idx" ON public."TopicGenerationMetrics" USING btree ("userId");


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
-- Name: CustomTopic CustomTopic_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CustomTopic"
    ADD CONSTRAINT "CustomTopic_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Fact Fact_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."CustomTopic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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
    ADD CONSTRAINT "Term_interestId_fkey" FOREIGN KEY ("interestId") REFERENCES public."Interest"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Term Term_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."CustomTopic"(id) ON UPDATE CASCADE ON DELETE SET NULL;


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

\unrestrict ruZlzf4B0I3F2CPqPZQ2jUGsmc74C9D0Ge3tVhtuX5ywVyl0pZ1XF1yTVWJy0Fy

