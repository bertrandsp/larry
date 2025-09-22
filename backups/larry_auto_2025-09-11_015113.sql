--
-- PostgreSQL database dump
--

\restrict QSif9KoL2Ks1i3VNltcXmf7g8KGHZVGxJbtdFLRbnjkcrL16NmFJkXIav7EN3kT

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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: CanonicalSet; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."CanonicalSet" (
    id text NOT NULL
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
    "gptGenerated" boolean NOT NULL,
    category text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "moderationNote" text,
    "moderationStatus" text DEFAULT 'pending'::text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "updatedByAdmin" boolean DEFAULT false NOT NULL
);


--
-- Name: MetricLog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."MetricLog" (
    id text NOT NULL,
    type text NOT NULL,
    "topicId" text,
    "termId" text,
    "factId" text,
    message text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: Term; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Term" (
    id text NOT NULL,
    "topicId" text NOT NULL,
    "canonicalSetId" text,
    term text NOT NULL,
    definition text NOT NULL,
    example text NOT NULL,
    source text NOT NULL,
    "sourceUrl" text,
    verified boolean NOT NULL,
    "gptGenerated" boolean NOT NULL,
    "confidenceScore" double precision NOT NULL,
    category text NOT NULL,
    "complexityLevel" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "moderationNote" text,
    "moderationStatus" text DEFAULT 'pending'::text NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "updatedByAdmin" boolean DEFAULT false NOT NULL
);


--
-- Name: Topic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."Topic" (
    id text NOT NULL,
    name text NOT NULL,
    "canonicalSetId" text
);


--
-- Name: User; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    subscription text DEFAULT 'free'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "openAiFirstPreferred" boolean DEFAULT false NOT NULL
);


--
-- Name: UserQuota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserQuota" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "currentUsage" integer DEFAULT 0 NOT NULL,
    "periodStart" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "lastReset" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: UserTopic; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."UserTopic" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "topicId" text NOT NULL,
    weight integer NOT NULL
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
-- Data for Name: CanonicalSet; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."CanonicalSet" (id) FROM stdin;
e8871648-d165-4df0-95e7-1c904f2e80e9
59952848-6ca4-41fb-a59a-e05228cf9f06
6f344c61-c746-439c-8697-542466270031
0e5bd29c-e049-4dce-9800-d094ae95b657
1417e3e7-5f9f-48d8-8c97-abb58900409d
b2b7a054-9e90-4f02-9f10-9350f3440fe9
9dfd9adc-d069-4a3c-b60f-e1df0f2bd460
1ea863f0-9d67-444e-b8a1-dd8523f42342
065fd81f-279a-47fa-9590-74b90089a501
68818923-e9ff-49cd-9f93-e7f5f007e560
\.


--
-- Data for Name: Fact; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Fact" (id, "topicId", fact, source, "sourceUrl", "gptGenerated", category, "createdAt", "moderationNote", "moderationStatus", "updatedAt", "updatedByAdmin") FROM stdin;
9efd9247-2759-4a69-ad63-7b09c6c762f5	ff520332-6b7f-45bd-a749-ff31b44dd180	tennis originated in the 12th century in france where it was played with the palm of the hand rackets came into use during the 16th century	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
283fd33d-ec77-4b1c-b20c-10d5a87bd0aa	ff520332-6b7f-45bd-a749-ff31b44dd180	the fastest serve ever recorded was hit by sam groth at 1637 mph 2634 kmh during a match in 2012	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
cd37f8e8-3bd3-4585-8937-d9323d27b074	ff520332-6b7f-45bd-a749-ff31b44dd180	tennis was first included in the olympic games in 1896 but was dropped after the 1924 games it returned as a full-medal sport in 1988	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
0d8e453a-a186-4fe0-bb12-606555646ff3	ff520332-6b7f-45bd-a749-ff31b44dd180	the longest match in professional tennis history took place at wimbledon in 2010 when john isner defeated nicolas mahut in a match that lasted 11 hours and 5 minutes over three days	AI Generated	\N	t	history	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
21c1de35-fef9-411f-81d3-1be2563d4b9c	ff520332-6b7f-45bd-a749-ff31b44dd180	the term love in tennis meaning zero is thought to come from the french word for egg loeuf because an egg looks like a zero	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
9afdbd67-18aa-48f2-953c-d0ea5bf2a006	ff520332-6b7f-45bd-a749-ff31b44dd180	the first tennis balls were made of wool or hair wrapped in leather modern tennis balls are made of hollow rubber with a felt coating	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
3f1ad00a-ed53-488f-bf1d-b06cd843916a	ff520332-6b7f-45bd-a749-ff31b44dd180	wimbledon one of the four grand slam events is the oldest tennis tournament in the world it began in 1877	AI Generated	\N	t	general	2025-09-08 21:42:30.337	\N	pending	2025-09-09 00:09:21.284	f
21b1b6e8-e1d7-4f52-9b17-cea3b987168d	535e5d75-e346-4f2b-9522-095f7b452646	anime represents about 60 of the worlds animated television shows	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
58e8284d-33f7-4664-a481-a086db14f958	535e5d75-e346-4f2b-9522-095f7b452646	the first known anime was released in 1917 nearly a century ago	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
a35b9813-8e0d-48ef-bbfb-650cb0a575a0	535e5d75-e346-4f2b-9522-095f7b452646	the longest running anime series is sazae-san with over 7500 episodes	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
02035310-d96e-46b5-85b9-3eb97eeed8fc	535e5d75-e346-4f2b-9522-095f7b452646	the highest-grossing anime film of all time is your name released in 2016	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
f9f54a80-4545-42ee-b632-a656b24c14c6	535e5d75-e346-4f2b-9522-095f7b452646	anime industry revenue exceeded 20 billion usd in 2019	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
ca8f28bf-8738-4731-809f-20610648d409	535e5d75-e346-4f2b-9522-095f7b452646	anime is not just popular in japan it has a vast international audience	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
7567145a-ef34-4e25-8524-7a3cba192572	535e5d75-e346-4f2b-9522-095f7b452646	in japan more paper is used to print manga than toilet paper	AI Generated	\N	t	general	2025-09-08 22:26:24.99	\N	pending	2025-09-09 00:09:21.284	f
4850fc21-def7-44c0-aaad-f8ebb5b7e6c1	535e5d75-e346-4f2b-9522-095f7b452646	anime is a significant part of japanese media culture and is a major export of japan influencing global pop culture in areas such as animation and graphic design	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
aa3ccd43-e16d-468b-a48a-5f60a5ed2f95	535e5d75-e346-4f2b-9522-095f7b452646	the longest running anime series is sazae-san which has aired over 7500 episodes since 1969	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
883b5d3e-ad5b-46f4-90a9-176836f750d5	535e5d75-e346-4f2b-9522-095f7b452646	hayao miyazaki a renowned anime director and co-founder of studio ghibli has won numerous awards for his work including an oscar for spirited away in 2003	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
13711158-517a-4616-b601-26afc82d4a1c	535e5d75-e346-4f2b-9522-095f7b452646	anime covers a wide range of genres from action and adventure to drama horror romance and science fiction catering to diverse audiences	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
cd0c8c91-ed54-42c4-916a-e8d173bca6ee	535e5d75-e346-4f2b-9522-095f7b452646	anime series often feature theme songs performed by popular japanese music artists and these songs can become major hits on their own	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
aa4a2178-61dd-4d03-84cb-c2058ba27ab4	535e5d75-e346-4f2b-9522-095f7b452646	anime and manga often explore complex themes and social issues and their storytelling can be as sophisticated as any literary work	AI Generated	\N	t	general	2025-09-08 22:26:34.68	\N	pending	2025-09-09 00:09:21.284	f
b3707cd1-7c82-46b1-b05a-7fdffc1df403	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were expected to live by a strict code of ethics called bushido or the way of the warrior which emphasized honor loyalty and bravery	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
86e9c065-8a2e-48cc-93c6-7aae0a028dcc	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurai class made up only about 10 of japans population during the feudal era	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
a38c98d7-4143-4efa-9e1b-301047f1db39	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were literate and well-educated they were expected to be cultured and to engage in practices such as tea ceremony and calligraphy	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
f8aeadd0-f746-4ba9-a7dd-215887809ef1	05baa19e-4e92-4e17-b040-66ef9114f2b6	the end of the samurai era also known as the edo period came in the late 19th century during the meiji restoration when the wearing of swords was outlawed and the samurai class was dissolved	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
b7526325-8bef-4f63-ad33-47ea26d490cd	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurais right to be the only armed force was officially abolished in 1876 and replaced by a modern western-style conscripted army	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
42221d64-05d4-4e5b-b3ff-a3366f3a7eb0	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai women also known as onna-bugeisha were trained in the same martial arts and strategy as their male counterparts and fought in combat as well	AI Generated	\N	t	general	2025-09-08 22:29:27.497	\N	pending	2025-09-09 00:09:21.284	f
1b0cc532-2062-4186-89ff-d6b5518ec5a1	05baa19e-4e92-4e17-b040-66ef9114f2b6	the word samurai roughly translates to one who serves originally the term referred to men who served as bodyguards to court nobles	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
75c53b20-5f8c-4943-8ccf-0ad835f4b6a8	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were expected to live according to the bushido code also known as the way of the warrior a strict ethical code influenced by confucianism that stressed loyalty to ones master self-discipline and respectful ethical behavior	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
cab13c21-c826-4222-9a46-4641e9e79ad7	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurai were skilled in various martial arts but their main weapon was the katana this sword is uniquely made extremely sharp and considered the soul of the samurai	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
b6519bdc-b926-4b22-a9c2-4266fab7f6be	05baa19e-4e92-4e17-b040-66ef9114f2b6	a samurai was recognized by his carrying the feared daisho the big sword little sword of the warrior these were the battle katana the big sword and the wakizashi the little sword	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
968b485e-7b46-40ec-8302-bc9a0aecfd59	05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai were allowed to carry their swords into places where commoners could not their swords were so important to their warrior persona that they would even sleep with them and the loss of a sword represented a great dishonor	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
032e8c53-7092-42f1-88a4-a97117534f03	05baa19e-4e92-4e17-b040-66ef9114f2b6	the samurai class was abolished by the meiji government in 1868 marking the end of feudalism in japan and the beginning of the modern era	AI Generated	\N	t	general	2025-09-08 22:29:32.458	\N	pending	2025-09-09 00:09:21.284	f
b2f1a899-dff0-4c2a-8bef-4318eeea05e2	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the game of basketball was invented by dr james naismith in 1891	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
30a38e32-6170-461b-a61d-2c8caaab460e	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the first basketball game was played with a soccer ball and two peach baskets as goals	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
3471347e-763d-4fd7-afea-3984b62d61c1	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the nba was founded in new york city on june 6 1946 as the basketball association of america baa	AI Generated	\N	t	history	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
468f93f9-e8de-432e-ba77-98719ba37654	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the shortest player ever to play in the nba is tyrone muggsy bogues who is 5 feet 3 inches tall	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
5e2c075e-59e3-453c-96e2-ef20a5d22c87	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the highest scoring nba game was between the detroit pistons and the denver nuggets in 1983 with a final score of 186-184	AI Generated	\N	t	general	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
0137a026-7bef-4561-b00f-7ab208c9ddc1	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the womens equivalent of the nba the wnba was founded in 1996	AI Generated	\N	t	history	2025-09-08 22:42:28.94	\N	pending	2025-09-09 00:09:21.284	f
bf1b798e-c30b-4dd3-9d86-2c58f94833a9	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	basketball was invented by dr james naismith in 1891	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
edd92222-346c-4d97-9703-c336eb8c6218	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	michael jordan considered one of the greatest basketball players won six nba championships with the chicago bulls	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
d6a5a001-1a60-4cee-925b-55d0d490356e	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	wilt chamberlain holds the record for the most points scored in a single nba game with 100 points	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
ca778011-7436-4546-b558-4174142bdc52	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the shortest player in the history of the nba is tyrone muggsy bogues who is 5 feet 3 inches tall	AI Generated	\N	t	history	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
2b36a4aa-2234-46fd-85b8-45a4059f0071	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	the boston celtics have won the most nba championships with 17 wins	AI Generated	\N	t	general	2025-09-08 22:42:32.244	\N	pending	2025-09-09 00:09:21.284	f
aabc027a-d963-4640-b06a-58f5e9e68968	e0ef2673-97c9-410f-b371-9a1ee72680d6	the word sommelier is derived from the middle french saumalier meaning a pack animal driver originally sommeliers were in charge of transporting supplies for the royal households	AI Generated	\N	t	general	2025-09-09 04:15:11.009	\N	pending	2025-09-09 04:15:11.009	f
7271b7a3-3716-44d5-a900-2cdf12b33b4b	e0ef2673-97c9-410f-b371-9a1ee72680d6	to become a certified sommelier one must pass a series of examinations by the court of master sommeliers or the wine  spirit education trust	AI Generated	\N	t	general	2025-09-09 04:15:11.009	\N	pending	2025-09-09 04:15:11.009	f
d6357515-96da-43e3-ae56-24b7e47656eb	e0ef2673-97c9-410f-b371-9a1ee72680d6	there are four levels of sommelier certification introductory certified advanced and master the master level is the highest and most difficult to achieve	AI Generated	\N	t	general	2025-09-09 04:15:11.009	\N	pending	2025-09-09 04:15:11.009	f
fbe45edb-8b55-4319-b1cf-a12b7312a047	e0ef2673-97c9-410f-b371-9a1ee72680d6	in addition to knowledge of wine sommeliers must also have a good understanding of beers ciders spirits and even cigars	AI Generated	\N	t	general	2025-09-09 04:15:11.009	\N	pending	2025-09-09 04:15:11.009	f
bef87a35-e58b-44b4-8cd1-6dd8f7310f73	e0ef2673-97c9-410f-b371-9a1ee72680d6	a sommelier uses a tastevin a small shallow silver cup to taste wine before serving it to guests	AI Generated	\N	t	general	2025-09-09 04:15:11.009	\N	pending	2025-09-09 04:15:11.009	f
33971a04-b71b-44b7-8e3d-2e8c1d615486	e0ef2673-97c9-410f-b371-9a1ee72680d6	there are only about 250 professionals worldwide who have reached the level of master sommelier	AI Generated	\N	t	general	2025-09-09 04:15:11.009	\N	pending	2025-09-09 04:15:11.009	f
68ef3471-09a1-4701-99b1-157117dc78ee	e0ef2673-97c9-410f-b371-9a1ee72680d6	the word sommelier is derived from the middle french saumalier meaning a pack animal driver this term was later used to refer to a court official charged with transportation of supplies	AI Generated	\N	t	general	2025-09-09 04:15:12.988	\N	pending	2025-09-09 04:15:12.988	f
4d29861f-f53e-434b-b857-2ecb53b5690c	e0ef2673-97c9-410f-b371-9a1ee72680d6	a professional sommelier often goes through extensive education and certification programs the court of master sommeliers and the wine  spirit education trust are two of the most prestigious	AI Generated	\N	t	general	2025-09-09 04:15:12.988	\N	pending	2025-09-09 04:15:12.988	f
b1e832e3-ed22-4a3f-8ee1-f9683e4c5dae	e0ef2673-97c9-410f-b371-9a1ee72680d6	sommeliers do not only deal with wine they can also specialize in other beverages such as beer spirits coffee tea and even water	AI Generated	\N	t	general	2025-09-09 04:15:12.988	\N	pending	2025-09-09 04:15:12.988	f
c635038c-14fb-4f46-8728-8b5fc4274f65	e0ef2673-97c9-410f-b371-9a1ee72680d6	despite the romantic image of the profession being a sommelier is hard work involving long hours extensive study and the need to keep up with an ever-changing wine industry	AI Generated	\N	t	general	2025-09-09 04:15:12.988	\N	pending	2025-09-09 04:15:12.988	f
54be4fe4-fb64-43b3-9ff4-a31332731850	e0ef2673-97c9-410f-b371-9a1ee72680d6	while wine and food pairing is a crucial part of a sommeliers job they also often work on the buying and pricing of wines creating wine lists and managing cellars	AI Generated	\N	t	general	2025-09-09 04:15:12.988	\N	pending	2025-09-09 04:15:12.988	f
b31277f7-6116-448a-91d4-7a3bc3ef8c4b	e0ef2673-97c9-410f-b371-9a1ee72680d6	there are four levels of sommelier certification introductory certified advanced and master the master sommelier diploma is the highest distinction a professional can attain in fine wine and beverage service	AI Generated	\N	t	general	2025-09-09 04:15:12.988	\N	pending	2025-09-09 04:15:12.988	f
c80081ae-effb-426d-a01e-ab2e6065b5e2	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning is a subset of artificial intelligence that focuses on the development of computer programs that can learn from and make decisions or predictions based on data	AI Generated	\N	t	statistics	2025-09-09 04:20:40.671	\N	pending	2025-09-09 04:20:40.671	f
6cff797b-1ec8-4acb-8b3e-5867db284fdd	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning algorithms are used across various industries including healthcare finance entertainment and transportation	AI Generated	\N	t	general	2025-09-09 04:20:40.671	\N	pending	2025-09-09 04:20:40.671	f
b974ac8f-30c2-4cd6-9a39-6592971492d3	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning algorithms improve their performance as the number of samples available for learning increases	AI Generated	\N	t	general	2025-09-09 04:20:40.671	\N	pending	2025-09-09 04:20:40.671	f
06fc32c9-25b2-4d3a-a587-f64800a28fa6	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	deep learning a subset of machine learning is inspired by the structure and function of the human brain and is particularly effective in image and speech recognition tasks	AI Generated	\N	t	general	2025-09-09 04:20:40.671	\N	pending	2025-09-09 04:20:40.671	f
b66aef4f-ca90-45ea-bdbb-3a0f2c0cb6ae	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	self-driving cars recommendation systems voice recognition systems like siri and alexa and email spam filters are all applications of machine learning	AI Generated	\N	t	general	2025-09-09 04:20:40.671	\N	pending	2025-09-09 04:20:40.671	f
13f32c5f-de0e-46c6-bea1-d92e30669fbd	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	googles search engine facebooks automatic friend tagging in photos and amazons product recommendation system all use machine learning algorithms	AI Generated	\N	t	general	2025-09-09 04:20:40.671	\N	pending	2025-09-09 04:20:40.671	f
60d228b0-9882-4e2d-a411-e58f04ab8aed	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning is a branch of artificial intelligence that gives computer systems the ability to learn from data without being explicitly programmed	AI Generated	\N	t	statistics	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
3c53a02c-acae-486d-9498-a6a5b7b1006a	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	the concept of machine learning was first proposed by arthur samuel in 1959	AI Generated	\N	t	general	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
78fb1da3-8de4-480e-a19a-0de4688ff44a	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning algorithms are used in a wide range of applications including email filtering detection of network intruders and computer vision	AI Generated	\N	t	general	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
389f7d5c-5b85-4cd9-bdc9-f76d471e47d5	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning is closely related to computational statistics which focuses on making predictions using computers	AI Generated	\N	t	statistics	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
1f2bff6f-b2e5-450d-aeaa-715bff294f1e	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	the self-driving car by google waymo uses machine learning to process the information picked up by its sensors and decide how to react to what it senses	AI Generated	\N	t	general	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
3d2cd104-e045-4011-ab28-fdd0bf70a570	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning is an integral part of recommendation systems used by online retailers and streaming services	AI Generated	\N	t	general	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
bc378bc2-9d54-4b47-b028-bee3e6774ed1	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	machine learning can be a cost-effective and more efficient way to analyze large volumes of data make predictions and help decision-making processes	AI Generated	\N	t	statistics	2025-09-09 04:20:42.375	\N	pending	2025-09-09 04:20:42.375	f
79b3f998-575f-4144-a31b-aa1d3406d3cb	6299eb79-88f3-443f-b110-d14372c85985	pickleball was invented in 1965 on bainbridge island a short ferry ride from seattle washington	AI Generated	\N	t	general	2025-09-09 04:24:18.123	\N	pending	2025-09-09 04:24:18.123	f
853881bc-9e3e-4180-95ce-2924812c123f	6299eb79-88f3-443f-b110-d14372c85985	the game was originally developed as a childrens backyard pastime but has become popular among adults as well	AI Generated	\N	t	general	2025-09-09 04:24:18.123	\N	pending	2025-09-09 04:24:18.123	f
62805d17-0484-4279-ab38-c7907563e71e	6299eb79-88f3-443f-b110-d14372c85985	despite its name pickleball has nothing to do with pickles the name comes from one of the inventors dogs pickles who would chase the ball and run off with it	AI Generated	\N	t	general	2025-09-09 04:24:18.123	\N	pending	2025-09-09 04:24:18.123	f
80a09b10-f23a-4505-88f6-cf5a39cb3e3c	6299eb79-88f3-443f-b110-d14372c85985	pickleball is played on a court that is the same size as a doubles badminton court	AI Generated	\N	t	general	2025-09-09 04:24:18.123	\N	pending	2025-09-09 04:24:18.123	f
a1d050eb-fa19-4028-810a-434409994fb8	6299eb79-88f3-443f-b110-d14372c85985	pickleball can be played as singles or doubles making it a versatile game for varying numbers of players	AI Generated	\N	t	general	2025-09-09 04:24:18.123	\N	pending	2025-09-09 04:24:18.123	f
6e1c8ead-75eb-4a6e-925d-fdc1b2a8e3be	6299eb79-88f3-443f-b110-d14372c85985	the sport is growing rapidly in popularity with more than 3 million players in the united states alone	AI Generated	\N	t	general	2025-09-09 04:24:18.123	\N	pending	2025-09-09 04:24:18.123	f
4669f6cd-e3bb-4e82-84c7-8c2d90ecaef4	6299eb79-88f3-443f-b110-d14372c85985	the game was actually named after the co-inventors dog pickles who would chase after and try to steal the ball	AI Generated	\N	t	general	2025-09-09 04:24:19.716	\N	pending	2025-09-09 04:24:19.716	f
dfd9048f-4d1c-41fd-a552-30e0cecf6f7e	6299eb79-88f3-443f-b110-d14372c85985	pickleball can be played both indoors and outdoors and can be played as singles or doubles	AI Generated	\N	t	general	2025-09-09 04:24:19.716	\N	pending	2025-09-09 04:24:19.716	f
e70d77dd-ebfa-4542-a7a3-a3a001550f28	6299eb79-88f3-443f-b110-d14372c85985	the sport has seen a surge in popularity in recent years with over 3 million players in the united states alone as of 2021	AI Generated	\N	t	general	2025-09-09 04:24:19.716	\N	pending	2025-09-09 04:24:19.716	f
4a7c734c-950e-4308-9ba9-486f77258d66	6299eb79-88f3-443f-b110-d14372c85985	the court used in pickleball is the same size as a doubles badminton court and the net is similar to a tennis net but is placed two inches lower	AI Generated	\N	t	general	2025-09-09 04:24:19.716	\N	pending	2025-09-09 04:24:19.716	f
d9afe50b-6568-4346-b73c-59d66f574c73	6299eb79-88f3-443f-b110-d14372c85985	pickleball is governed internationally by the international federation of pickleball ifp which maintains the official rules of the sport	AI Generated	\N	t	general	2025-09-09 04:24:19.716	\N	pending	2025-09-09 04:24:19.716	f
39354dc1-71f1-4f1f-90c9-285b7d2a5b58	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	the term artificial intelligence was first coined at the dartmouth conference in 1956	AI Generated	\N	t	general	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
dd5f86a3-0590-4334-9f28-8b2b11a935d7	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	ai can be classified into two types narrow ai which is designed to perform a narrow task and general ai which can perform any intellectual task that a human being can do	AI Generated	\N	t	general	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
f76d186b-a55c-47f3-8187-3c7100908b22	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	googles alphago an ai program defeated the world champion go player in 2016 a feat previously thought to be at least a decade away	AI Generated	\N	t	general	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
7a08e8c3-c838-401c-abc6-b2fdb7965862	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	as per a mckinsey report ai could potentially deliver additional global economic activity of around 13 trillion by 2030	AI Generated	\N	t	general	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
8384d0e4-c21e-44f1-b28e-5360a5fdb9e7	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	artificial intelligence can help in predicting and detecting diseases in early stages its being widely used in the healthcare industry	AI Generated	\N	t	general	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
4681e5f1-0a1b-4445-a623-719b164afa7b	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	as of now japan is the country with the highest number of robots employed in different sectors taking advantage of ai technology	AI Generated	\N	t	benefit	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
add82216-b485-4fe5-a942-893b324a3802	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	ai has been implemented in various fields including healthcare finance transportation and more and its expected to create 23 million jobs by 2022	AI Generated	\N	t	general	2025-09-09 04:42:39.004	\N	pending	2025-09-09 04:42:39.004	f
5505b04d-b064-414a-94be-41154257de65	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	the term artificial intelligence was first coined by john mccarthy in 1956 at the dartmouth conference	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
b907ebf0-f15f-4ff1-8971-efd46962e761	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	artificial intelligence can be divided into two different types narrow artificial intelligence which is ai that is designed to perform a narrow task and general artificial intelligence which is ai that performs any intellectual task that a human being can do	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
93ede8a6-78bc-4e4d-a415-801cc25acdcd	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	elon musk the ceo of tesla and spacex has voiced serious concerns about artificial intelligence calling it the biggest existential threat to humanity	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
6e0f28db-134b-4622-983b-9c12f6b50a55	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	artificial intelligence can be used in a wide range of fields including medical diagnosis stock trading robot control law remote sensing scientific discovery and toys	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
86bb1c9d-edfd-47be-9dbc-c666d48b3e32	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	ai is projected to increase global gdp by up to 14 between now and 2030 which means an extra 157 trillion potentially available	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
19c601db-54c0-438a-a7c9-12bd8a29fbe4	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	googles deepmind ai alphago was the first to beat a world champion go player in 2016	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
56140d4a-eda8-4714-af29-310a771d0709	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	by 2025 the global ai market is expected to be almost 60 billion in 2016 it was 14 billion	AI Generated	\N	t	general	2025-09-09 04:42:43.499	\N	pending	2025-09-09 04:42:43.499	f
bdae32ed-7440-4983-bcbf-91fe5441423a	2d06fa5d-b462-47d3-bdf0-ad76525993b6	quantum computers can process massive and complex datasets more efficiently than classical computers	AI Generated	\N	t	statistics	2025-09-09 04:42:47.598	\N	pending	2025-09-09 04:42:47.598	f
d462b234-8808-4552-970f-4f01f858d2eb	2d06fa5d-b462-47d3-bdf0-ad76525993b6	in 2019 googles quantum computer named sycamore claimed quantum supremacy after it reportedly did a calculation in 200 seconds that would have taken the worlds fastest supercomputer 10000 years	AI Generated	\N	t	general	2025-09-09 04:42:47.598	\N	pending	2025-09-09 04:42:47.598	f
c7679409-2a76-4278-af38-51be72239005	2d06fa5d-b462-47d3-bdf0-ad76525993b6	quantum computing could revolutionize fields such as cryptography material science pharmaceuticals ai and more	AI Generated	\N	t	general	2025-09-09 04:42:47.598	\N	pending	2025-09-09 04:42:47.598	f
29d37c60-ab72-4d63-b2eb-d0cfcea3660b	2d06fa5d-b462-47d3-bdf0-ad76525993b6	the concept of quantum computing was first introduced by physicist richard feynman in 1982	AI Generated	\N	t	general	2025-09-09 04:42:47.598	\N	pending	2025-09-09 04:42:47.598	f
fffead26-9420-49c1-ab98-d6465535ad83	2d06fa5d-b462-47d3-bdf0-ad76525993b6	the biggest challenge in quantum computing is maintaining the qubits state as it requires very specific conditions such as extreme cold and isolation from the external environment	AI Generated	\N	t	challenge	2025-09-09 04:42:47.598	\N	pending	2025-09-09 04:42:47.598	f
a4369b36-3105-49fa-8308-a32fccf86bf3	2d06fa5d-b462-47d3-bdf0-ad76525993b6	ibm google microsoft and many other tech giants are investing heavily in the research and development of quantum computing technology	AI Generated	\N	t	general	2025-09-09 04:42:47.598	\N	pending	2025-09-09 04:42:47.598	f
5ca7ce8c-815c-4309-956e-58589a621e72	e56556fd-4e45-4394-be3f-7e7d83a36367	blockchain technology was first outlined in 1991 but didnt come to fruition until it was adopted by satoshi nakamoto in creating bitcoin in 2009	AI Generated	\N	t	tech-fact	2025-09-09 04:43:13.617	\N	pending	2025-09-09 04:43:13.617	f
d75d9286-6220-45a6-b0ae-999650eb5379	e56556fd-4e45-4394-be3f-7e7d83a36367	the first digital currency to use blockchain technology was bitcoin	AI Generated	\N	t	tech-fact	2025-09-09 04:43:13.617	\N	pending	2025-09-09 04:43:13.617	f
38e30895-9697-49a4-966a-2d44e99597cc	e56556fd-4e45-4394-be3f-7e7d83a36367	as of 2021 there are over 4000 cryptocurrencies in existence all of which use some form of blockchain technology	AI Generated	\N	t	tech-fact	2025-09-09 04:43:13.617	\N	pending	2025-09-09 04:43:13.617	f
804a3563-10a0-4c34-aa3b-037222c26ca4	e56556fd-4e45-4394-be3f-7e7d83a36367	while blockchain is most commonly associated with cryptocurrency it has potential applications in many other areas including supply chain management healthcare and voting systems	AI Generated	\N	t	tech-fact	2025-09-09 04:43:13.617	\N	pending	2025-09-09 04:43:13.617	f
1b795cb9-3e79-47c4-a7b2-2db8140478d8	e56556fd-4e45-4394-be3f-7e7d83a36367	in blockchain a transaction is processed only after it is verified by multiple nodes making the system highly secure against fraud and hacking	AI Generated	\N	t	tech-fact	2025-09-09 04:43:13.617	\N	pending	2025-09-09 04:43:13.617	f
2110b606-af61-4214-9ba5-d75e069867e0	e56556fd-4e45-4394-be3f-7e7d83a36367	the energy consumption of blockchain especially bitcoin is a major concern as of late 2021 the bitcoin network consumes more energy annually than some countries like the netherlands and argentina	AI Generated	\N	t	tech-fact	2025-09-09 04:43:13.617	\N	pending	2025-09-09 04:43:13.617	f
310c1dcd-20e2-4860-b3ce-a51b383e0a2c	2d06fa5d-b462-47d3-bdf0-ad76525993b6	quantum computers use the principles of quantum mechanics to process information which may allow them to solve complex problems much faster than classical computers	AI Generated	\N	t	challenge	2025-09-09 04:43:14.133	\N	pending	2025-09-09 04:43:14.133	f
24e98a33-be15-4aa9-90dd-d8f1a81c5bed	2d06fa5d-b462-47d3-bdf0-ad76525993b6	in 2019 google claimed to have achieved quantum supremacy when its quantum computer solved a problem in 200 seconds that it claimed would take a supercomputer 10000 years	AI Generated	\N	t	challenge	2025-09-09 04:43:14.133	\N	pending	2025-09-09 04:43:14.133	f
25a62d79-2d13-498b-9d91-fd8021727622	2d06fa5d-b462-47d3-bdf0-ad76525993b6	quantum computers are still in the experimental stage and it is not yet clear when they will be commercially available	AI Generated	\N	t	general	2025-09-09 04:43:14.133	\N	pending	2025-09-09 04:43:14.133	f
9852223d-9a1d-417c-9d19-f565d4a441fa	2d06fa5d-b462-47d3-bdf0-ad76525993b6	qubits are the quantum version of classical binary bits unlike binary bits which are either 0 or 1 a qubit can be both at the same time thanks to a property called superposition	AI Generated	\N	t	general	2025-09-09 04:43:14.133	\N	pending	2025-09-09 04:43:14.133	f
cc542852-fb82-4346-aa49-23187c7593a8	2d06fa5d-b462-47d3-bdf0-ad76525993b6	another key property of qubits is entanglement which links two qubits together so that the state of one instantaneously affects the state of the other no matter the distance between them	AI Generated	\N	t	general	2025-09-09 04:43:14.133	\N	pending	2025-09-09 04:43:14.133	f
a353db29-93ee-4a73-8bfd-605b5f212839	2d06fa5d-b462-47d3-bdf0-ad76525993b6	quantum computing could revolutionize fields such as cryptography optimization and drug discovery by solving problems that are currently too complex for classical computers	AI Generated	\N	t	challenge	2025-09-09 04:43:14.133	\N	pending	2025-09-09 04:43:14.133	f
79d61b21-b773-4df0-93c0-425d05f07a77	e56556fd-4e45-4394-be3f-7e7d83a36367	the concept of blockchain was first introduced in 2008 by an entity using the pseudonym satoshi nakamoto	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
4e74c9b1-c657-4976-a9d7-2f6bbec76182	e56556fd-4e45-4394-be3f-7e7d83a36367	blockchain technology is being used in various industries including finance supply chain healthcare and more due to its ability to provide transparency security and efficiency	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
e1743b17-105d-42e1-985b-9ad313e0e1c8	e56556fd-4e45-4394-be3f-7e7d83a36367	the data in a blockchain is almost impossible to alter because of its cryptographic hash functions and decentralized nature	AI Generated	\N	t	statistics	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
d270af94-0806-4685-8c7d-9878084cd85d	e56556fd-4e45-4394-be3f-7e7d83a36367	bitcoin was the first major application of blockchain technology and remains one of the most valuable and influential cryptocurrencies	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
453cc22d-a6c7-46cc-a076-f4cf7af2a564	e56556fd-4e45-4394-be3f-7e7d83a36367	in addition to financial transactions blockchain can also be used to record any type of exchange agreements contracts and even personal identification	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
2ba99c95-3540-4a4e-aff0-f9764447d586	e56556fd-4e45-4394-be3f-7e7d83a36367	blockchain technology can potentially eliminate the need for intermediaries in many industries which can result in faster transactions and reduced costs	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
a5dc2321-9fc8-4635-b924-bde5f39fc73a	e56556fd-4e45-4394-be3f-7e7d83a36367	ethereum a major blockchain platform introduced the concept of smart contracts which are programmable scripts that self-execute when certain conditions are met	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
af378156-3d17-459f-8394-6c7cf4a77d2c	e56556fd-4e45-4394-be3f-7e7d83a36367	the energy consumption of blockchain particularly bitcoin has been a subject of controversy some bitcoin miners use as much energy as entire countries	AI Generated	\N	t	tech-fact	2025-09-09 04:43:33.284	\N	pending	2025-09-09 04:43:33.284	f
\.


--
-- Data for Name: MetricLog; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."MetricLog" (id, type, "topicId", "termId", "factId", message, metadata, "createdAt") FROM stdin;
4e3bf151-5dae-404a-910a-0fa47758fb12	test	\N	\N	\N	Test metric log	{"test": true}	2025-09-09 04:22:09.918
c3a0af8f-a72c-4eec-83c1-7c73dfee57d4	openai	ff520332-6b7f-45bd-a749-ff31b44dd180	\N	\N	Test OpenAI usage	{"model": "gpt-4o", "promptType": "test", "inputTokens": 100, "outputTokens": 50}	2025-09-09 04:22:58.402
4963937c-ddc3-4083-9625-9bfde15baa3a	content_generation	ff520332-6b7f-45bd-a749-ff31b44dd180	\N	\N	Content generation completed	{"event": "completed", "status": "success", "factsGenerated": 3, "termsGenerated": 5}	2025-09-09 04:22:58.406
85779ab4-aab5-4807-89b1-b93bbceaf359	content_generation	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	Content generation started: started	{"event": "started", "status": "started", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Artificial Intelligence"}	2025-09-09 04:42:10.187
dda06d7a-ace4-4145-953b-b279fb8e128c	content_generation	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	Content generation started: started	{"event": "started", "status": "started", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Quantum Computing"}	2025-09-09 04:42:10.187
900e78de-566f-45d9-b665-096e87a0f697	content_generation	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	Content generation started: started	{"event": "started", "status": "started", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Artificial Intelligence"}	2025-09-09 04:42:10.187
7136f654-500f-4d04-8b7f-efc329065213	openai	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	OpenAI request: generate_terms_and_facts using gpt-4o	{"model": "gpt-4o", "userTier": "free", "factsCount": 7, "promptType": "generate_terms_and_facts", "termsCount": 11, "inputTokens": 106, "outputTokens": 900}	2025-09-09 04:42:38.308
13b7bfc2-b892-4ccc-abf9-37e4473ef979	pipeline	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	Pipeline post_processing: success	{"event": "post_processing", "stats": {"enrichedCount": 11, "originalCount": 11, "normalizedCount": 11, "deduplicatedCount": 11, "duplicatesRemoved": 0, "confidenceImproved": 0}, "status": "success", "originalFacts": 7, "originalTerms": 11, "processedFacts": 7, "processedTerms": 11}	2025-09-09 04:42:38.312
0b6b9398-43b7-4870-9c29-abd021d77f5a	content_generation	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	Content generation completed: completed	{"event": "completed", "status": "completed", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Artificial Intelligence", "duplicateStats": {"totalFacts": 7, "totalTerms": 11, "uniqueFacts": 7, "uniqueTerms": 11, "duplicateFacts": 0, "duplicateTerms": 0}, "factsGenerated": 7, "termsGenerated": 11, "postProcessingStats": {"enrichedCount": 11, "originalCount": 11, "normalizedCount": 11, "deduplicatedCount": 11, "duplicatesRemoved": 0, "confidenceImproved": 0}}	2025-09-09 04:42:39.007
2a5a82d1-8b44-418d-90c4-29fba3404822	content_generation	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	Content generation started: started	{"event": "started", "status": "started", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Quantum Computing"}	2025-09-09 04:42:39.011
81e93f75-d08a-4326-91c7-102116bef38a	openai	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	OpenAI request: generate_terms_and_facts using gpt-4o	{"model": "gpt-4o", "userTier": "free", "factsCount": 6, "promptType": "generate_terms_and_facts", "termsCount": 11, "inputTokens": 105, "outputTokens": 850}	2025-09-09 04:42:42.537
cd34b867-9022-4f9b-91c0-c2a59c2a2a86	pipeline	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	Pipeline post_processing: success	{"event": "post_processing", "stats": {"enrichedCount": 11, "originalCount": 11, "normalizedCount": 11, "deduplicatedCount": 11, "duplicatesRemoved": 0, "confidenceImproved": 0}, "status": "success", "originalFacts": 6, "originalTerms": 11, "processedFacts": 6, "processedTerms": 11}	2025-09-09 04:42:42.544
f19ed9ac-0297-41b6-9ace-fe53ed4ea6b3	openai	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	OpenAI request: generate_terms_and_facts using gpt-4o	{"model": "gpt-4o", "userTier": "free", "factsCount": 7, "promptType": "generate_terms_and_facts", "termsCount": 10, "inputTokens": 106, "outputTokens": 850}	2025-09-09 04:42:43.348
f82ee126-da3a-4c38-8ac7-9e545769ae79	pipeline	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	Pipeline post_processing: success	{"event": "post_processing", "stats": {"enrichedCount": 10, "originalCount": 10, "normalizedCount": 10, "deduplicatedCount": 10, "duplicatesRemoved": 0, "confidenceImproved": 0}, "status": "success", "originalFacts": 7, "originalTerms": 10, "processedFacts": 7, "processedTerms": 10}	2025-09-09 04:42:43.355
8ddaf72b-b61d-40b5-a885-175a263ef42e	content_generation	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	\N	\N	Content generation completed: completed	{"event": "completed", "status": "completed", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Artificial Intelligence", "duplicateStats": {"totalFacts": 7, "totalTerms": 10, "uniqueFacts": 7, "uniqueTerms": 2, "duplicateFacts": 0, "duplicateTerms": 8}, "factsGenerated": 7, "termsGenerated": 2, "postProcessingStats": {"enrichedCount": 10, "originalCount": 10, "normalizedCount": 10, "deduplicatedCount": 10, "duplicatesRemoved": 0, "confidenceImproved": 0}}	2025-09-09 04:42:43.502
fd428a9f-34c8-40a3-b11b-b63a47b354c7	content_generation	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	Content generation started: started	{"event": "started", "status": "started", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Blockchain Technology"}	2025-09-09 04:42:43.506
c8d70dcc-effc-47e8-acca-1c8a9be52f3e	content_generation	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	Content generation completed: completed	{"event": "completed", "status": "completed", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Quantum Computing", "duplicateStats": {"totalFacts": 6, "totalTerms": 11, "uniqueFacts": 6, "uniqueTerms": 11, "duplicateFacts": 0, "duplicateTerms": 0}, "factsGenerated": 6, "termsGenerated": 11, "postProcessingStats": {"enrichedCount": 11, "originalCount": 11, "normalizedCount": 11, "deduplicatedCount": 11, "duplicatesRemoved": 0, "confidenceImproved": 0}}	2025-09-09 04:42:47.602
f8c81d52-93b2-4158-ba38-b774b4e7858c	content_generation	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	Content generation started: started	{"event": "started", "status": "started", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Blockchain Technology"}	2025-09-09 04:42:47.605
c7f36610-01f2-4317-a936-25ceeb02de9b	openai	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	OpenAI request: generate_terms_and_facts using gpt-4o	{"model": "gpt-4o", "userTier": "free", "factsCount": 6, "promptType": "generate_terms_and_facts", "termsCount": 12, "inputTokens": 106, "outputTokens": 900}	2025-09-09 04:43:11.971
a94a0e71-17cd-4e7a-8e04-a4e82dec3161	pipeline	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	Pipeline post_processing: success	{"event": "post_processing", "stats": {"enrichedCount": 12, "originalCount": 12, "normalizedCount": 12, "deduplicatedCount": 12, "duplicatesRemoved": 0, "confidenceImproved": 0}, "status": "success", "originalFacts": 6, "originalTerms": 12, "processedFacts": 6, "processedTerms": 12}	2025-09-09 04:43:11.977
54734e91-cb09-45f4-9dd9-e115c0cdc5a4	openai	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	OpenAI request: generate_terms_and_facts using gpt-4o	{"model": "gpt-4o", "userTier": "free", "factsCount": 6, "promptType": "generate_terms_and_facts", "termsCount": 10, "inputTokens": 105, "outputTokens": 800}	2025-09-09 04:43:12.21
cb78f3fe-57e3-48fc-a131-48d5a0fd0e87	pipeline	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	Pipeline post_processing: success	{"event": "post_processing", "stats": {"enrichedCount": 10, "originalCount": 10, "normalizedCount": 10, "deduplicatedCount": 10, "duplicatesRemoved": 0, "confidenceImproved": 0}, "status": "success", "originalFacts": 6, "originalTerms": 10, "processedFacts": 6, "processedTerms": 10}	2025-09-09 04:43:12.218
4f76df78-e63a-4103-aee9-8accc52e7847	content_generation	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	Content generation completed: completed	{"event": "completed", "status": "completed", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Blockchain Technology", "duplicateStats": {"totalFacts": 6, "totalTerms": 12, "uniqueFacts": 6, "uniqueTerms": 12, "duplicateFacts": 0, "duplicateTerms": 0}, "factsGenerated": 6, "termsGenerated": 12, "postProcessingStats": {"enrichedCount": 12, "originalCount": 12, "normalizedCount": 12, "deduplicatedCount": 12, "duplicatesRemoved": 0, "confidenceImproved": 0}}	2025-09-09 04:43:13.62
08474c79-acac-4339-95bd-a06c9abbeeb6	content_generation	2d06fa5d-b462-47d3-bdf0-ad76525993b6	\N	\N	Content generation completed: completed	{"event": "completed", "status": "completed", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Quantum Computing", "duplicateStats": {"totalFacts": 6, "totalTerms": 10, "uniqueFacts": 6, "uniqueTerms": 2, "duplicateFacts": 0, "duplicateTerms": 8}, "factsGenerated": 6, "termsGenerated": 2, "postProcessingStats": {"enrichedCount": 10, "originalCount": 10, "normalizedCount": 10, "deduplicatedCount": 10, "duplicatesRemoved": 0, "confidenceImproved": 0}}	2025-09-09 04:43:14.136
9ab26c5f-e370-4a68-83a3-2c63484188e5	openai	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	OpenAI request: generate_terms_and_facts using gpt-4o	{"model": "gpt-4o", "userTier": "free", "factsCount": 8, "promptType": "generate_terms_and_facts", "termsCount": 15, "inputTokens": 106, "outputTokens": 1150}	2025-09-09 04:43:32.455
f185bd11-301d-456e-bfb1-976200d9f458	pipeline	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	Pipeline post_processing: success	{"event": "post_processing", "stats": {"enrichedCount": 15, "originalCount": 15, "normalizedCount": 15, "deduplicatedCount": 15, "duplicatesRemoved": 0, "confidenceImproved": 0}, "status": "success", "originalFacts": 8, "originalTerms": 15, "processedFacts": 8, "processedTerms": 15}	2025-09-09 04:43:32.459
b6ead609-ab69-4b4c-9fc2-e3f5a2a8a77e	content_generation	e56556fd-4e45-4394-be3f-7e7d83a36367	\N	\N	Content generation completed: completed	{"event": "completed", "status": "completed", "userId": "ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe", "userTier": "free", "topicName": "Blockchain Technology", "duplicateStats": {"totalFacts": 8, "totalTerms": 15, "uniqueFacts": 8, "uniqueTerms": 6, "duplicateFacts": 0, "duplicateTerms": 9}, "factsGenerated": 8, "termsGenerated": 6, "postProcessingStats": {"enrichedCount": 15, "originalCount": 15, "normalizedCount": 15, "deduplicatedCount": 15, "duplicatesRemoved": 0, "confidenceImproved": 0}}	2025-09-09 04:43:33.287
86e16b9d-92b8-48ac-aa72-35b9dfb85e2f	moderation	e56556fd-4e45-4394-be3f-7e7d83a36367	4acdd69c-5d22-4193-9df6-4aefedde1272	\N	Moderation rejected for term	{"note": "This is the definition for blockchain", "action": "rejected"}	2025-09-09 19:49:07.477
1e1eeba0-8f61-4177-aafe-433471d02b8a	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 5, "pipeline": "source-first", "userTier": "free", "topicName": "anime"}	2025-09-10 21:27:01.772
f7492cab-d16e-45c5-bf12-af412bc734f3	content_generation	\N	\N	\N	Content generation failed: failed	{"error": "(0 , openAiService_1.generateVocabulary) is not a function", "event": "failed", "status": "failed", "pipeline": "source-first", "userTier": "free", "topicName": "anime", "processingTime": 1182}	2025-09-10 21:27:02.919
877dc614-a7b3-40f3-878f-5174d0604749	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 8, "pipeline": "openai-first", "userTier": "free", "topicName": "blockchain"}	2025-09-10 21:27:02.928
6562045b-027d-498d-b9cf-dafe9dd96186	content_generation	\N	\N	\N	Content generation failed: failed	{"error": "(0 , openAiService_1.generateVocabulary) is not a function", "event": "failed", "status": "failed", "pipeline": "openai-first", "userTier": "free", "topicName": "blockchain", "processingTime": 9}	2025-09-10 21:27:02.936
4924c7d9-76c7-4f8d-a6c8-71c0c48c3b05	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 3, "numTerms": 10, "pipeline": "source-first", "userTier": "free", "topicName": "machine learning"}	2025-09-10 21:27:02.942
921b6b46-1746-4182-9000-51a2701f1cbb	content_generation	\N	\N	\N	Content generation failed: failed	{"error": "(0 , openAiService_1.generateVocabulary) is not a function", "event": "failed", "status": "failed", "pipeline": "source-first", "userTier": "free", "topicName": "machine learning", "processingTime": 1061}	2025-09-10 21:27:04.006
d2e856f2-76fb-4a52-bd13-6e86b2ca510b	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 5, "pipeline": "source-first", "userTier": "free", "topicName": "anime"}	2025-09-10 21:28:44.773
f2186497-2dc5-4d6d-a288-170970870916	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.005634999999999999, "jobId": "quick-gen-1757539724745-otza6r2su", "model": "gpt-4o", "topic": "anime", "totalTokens": 1187, "promptTokens": 399, "completionTokens": 788}}	2025-09-10 21:28:55.988
06361654-3bc6-46b4-ad58-0cabd09d9a91	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 10, "processingTime": 11248, "termsGenerated": 5, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "anime", "factsGenerated": 10, "processingTime": 11248, "termsGenerated": 5}	2025-09-10 21:28:56
a7e8c25b-6329-49be-b01f-82ede4581946	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 8, "pipeline": "openai-first", "userTier": "free", "topicName": "blockchain"}	2025-09-10 21:28:56.009
d0d54a9e-e7f6-4e7b-bf74-57795f00088b	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.00988, "jobId": "quick-gen-1757539736006-9pee3hcdb", "model": "gpt-4o", "topic": "blockchain", "totalTokens": 2081, "promptTokens": 400, "completionTokens": 1681}}	2025-09-10 21:29:19.075
d7d86efa-4c29-4828-b789-ff8002403e98	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 10, "processingTime": 25418, "termsGenerated": 8, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "blockchain", "factsGenerated": 10, "processingTime": 25418, "termsGenerated": 8}	2025-09-10 21:29:21.427
59073804-3552-4256-be38-5c7f114ba7bd	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 3, "numTerms": 10, "pipeline": "source-first", "userTier": "free", "topicName": "machine learning"}	2025-09-10 21:29:21.436
f0ccb2a1-e598-4422-b0fb-76405cce520a	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.00847, "jobId": "gen-1757539761433-1qcl3x9gl", "model": "gpt-4o", "topic": "machine learning", "totalTokens": 1784, "promptTokens": 403, "completionTokens": 1381}}	2025-09-10 21:29:41.51
031a956f-967f-4d97-bdf4-909725484e7f	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 3, "processingTime": 20085, "termsGenerated": 10, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "machine learning", "factsGenerated": 3, "processingTime": 20085, "termsGenerated": 10}	2025-09-10 21:29:41.522
583bba3d-64ef-4f42-81af-8e8e23e32ae6	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "openai-first", "userTier": "free", "topicName": "music production"}	2025-09-10 21:53:51.515
954877c3-5bff-4964-a530-f4f4640b60cf	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.005990000000000001, "jobId": "gen-1757541231491-vuw8oyas2", "model": "gpt-4o", "topic": "music production", "totalTokens": 1263, "promptTokens": 403, "completionTokens": 860}}	2025-09-10 21:54:01.159
a7d6356c-4d3e-42e3-ad1d-adcce0af4117	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 10740, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 10740, "termsGenerated": 4}	2025-09-10 21:54:02.233
2f0808da-f267-4791-8881-1f480988aa78	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "source-first", "userTier": "free", "topicName": "music production"}	2025-09-10 21:58:40.868
50bd3c12-b1e0-4375-b5b1-a2ee912aafd1	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.004025, "jobId": "gen-1757541520865-p7s6sozuo", "model": "gpt-4o", "topic": "music production", "totalTokens": 849, "promptTokens": 403, "completionTokens": 446}}	2025-09-10 21:58:52.663
644e92b1-2f66-4e46-ae54-61dd635542de	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 11830, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 11830, "termsGenerated": 4}	2025-09-10 21:58:52.699
bdc57a2f-c9ba-4f68-a5da-7244b52fde33	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 4, "pipeline": "source-first", "userTier": "free", "topicName": "music production"}	2025-09-10 21:59:30.217
c55bf0fc-f800-40d6-ae94-f5b81a1ec54f	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.00494, "jobId": "quick-gen-1757541570208-hqlvexovq", "model": "gpt-4o", "topic": "music production", "totalTokens": 1040, "promptTokens": 403, "completionTokens": 637}}	2025-09-10 21:59:42.233
a6f1a818-f317-4d72-94d6-51145c5a92be	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 10, "processingTime": 12036, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "music production", "factsGenerated": 10, "processingTime": 12036, "termsGenerated": 4}	2025-09-10 21:59:42.247
2c4391a5-6fbf-48f8-8169-8865369cef07	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "source-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:00:00.598
bcfe41c6-9406-4d9f-a3e1-5e256026c6f4	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0036425, "jobId": "gen-1757541600590-2r0lv2198", "model": "gpt-4o", "topic": "music production", "totalTokens": 768, "promptTokens": 382, "completionTokens": 386}}	2025-09-10 22:00:09.843
46c9277f-e3c1-41ae-b054-0906277f99a9	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 9263, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 9263, "termsGenerated": 4}	2025-09-10 22:00:09.857
340dffd1-ad87-4032-91db-4bdb2a57e865	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "source-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:01:00.084
1167934b-9c46-476a-8824-90e85fccf3f7	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.004372500000000001, "jobId": "gen-1757541660060-tlzhy4q4j", "model": "gpt-4o", "topic": "music production", "totalTokens": 922, "promptTokens": 403, "completionTokens": 519}}	2025-09-10 22:01:08.967
99509121-36f8-471f-8919-68b11fad857e	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 8917, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 8917, "termsGenerated": 4}	2025-09-10 22:01:08.981
6fa4bf75-d5b2-4be9-a8c2-49dc3a6a8af9	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "openai-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:01:24.143
5841854f-0aee-4f8f-95d4-bc3a11a6a2eb	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0059725, "jobId": "gen-1757541684138-n4rabu857", "model": "gpt-4o", "topic": "music production", "totalTokens": 1259, "promptTokens": 403, "completionTokens": 856}}	2025-09-10 22:01:41.31
5e2ed76f-56e7-4d5d-8123-141aa48b5e1d	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 17995, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 17995, "termsGenerated": 4}	2025-09-10 22:01:42.136
f803f3b0-4d68-44f7-84dc-1fdd355f23fd	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 4, "pipeline": "openai-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:04:01.821
9e98a876-db4e-458f-b801-8fbd563fa3c2	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.007445, "jobId": "quick-gen-1757541841791-xb8c36qc5", "model": "gpt-4o", "topic": "music production", "totalTokens": 1569, "promptTokens": 403, "completionTokens": 1166}}	2025-09-10 22:04:15.124
84d4cc6c-6f2f-4a45-9f4b-e1f4dbe44e9c	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 10, "processingTime": 13864, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "music production", "factsGenerated": 10, "processingTime": 13864, "termsGenerated": 4}	2025-09-10 22:04:15.658
54e87718-072b-43f1-bdad-8b946c0420ca	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "openai-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:05:53.142
8d13a871-8fd7-4aab-975d-d91d19586a95	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0058275, "jobId": "gen-1757541953137-bk5kby0rt", "model": "gpt-4o", "topic": "music production", "totalTokens": 1228, "promptTokens": 403, "completionTokens": 825}}	2025-09-10 22:06:05.51
19ed92be-d502-41f1-b72f-1a4408ca1be0	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 12747, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 12747, "termsGenerated": 4}	2025-09-10 22:06:05.888
bdb32ae6-6aa0-4d77-8230-b1a280d4c9d6	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "openai-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:15:36.835
0c05d970-83e1-43de-8ec4-e25c0ab62387	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.005322500000000001, "jobId": "gen-1757542536814-9zd1jyn4u", "model": "gpt-4o", "topic": "music production", "totalTokens": 1122, "promptTokens": 382, "completionTokens": 740}}	2025-09-10 22:15:50.831
8d9293f9-2c5f-42d8-932d-6c83f56bf9f3	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 14617, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 14617, "termsGenerated": 4}	2025-09-10 22:15:51.434
d0a1ea16-f024-42bd-9173-26e6b96c3792	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 1, "numTerms": 4, "pipeline": "openai-first", "userTier": "free", "topicName": "music production"}	2025-09-10 22:16:56.314
b9d5e9c5-5c40-4648-9edd-afbffb00b7cf	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0058275, "jobId": "gen-1757542616302-3lw4x0z8v", "model": "gpt-4o", "topic": "music production", "totalTokens": 1228, "promptTokens": 382, "completionTokens": 846}}	2025-09-10 22:17:15.175
8c60b737-93ad-4230-b2bf-a00425fa3d9f	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 1, "processingTime": 19297, "termsGenerated": 4, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "music production", "factsGenerated": 1, "processingTime": 19297, "termsGenerated": 4}	2025-09-10 22:17:15.602
8de2727e-b295-4f01-ab23-809d5fe4a552	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 4, "numTerms": 7, "pipeline": "openai-first", "userTier": "free", "topicName": "strength training"}	2025-09-10 22:17:56.756
d4d70450-d0be-4c06-908f-449903bb366e	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0076025, "jobId": "gen-1757542676752-q2j16vmji", "model": "gpt-4o", "topic": "strength training", "totalTokens": 1602, "promptTokens": 382, "completionTokens": 1220}}	2025-09-10 22:18:10.817
65f854b5-66d0-43df-bf5a-94f54c1b8518	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 4, "processingTime": 15980, "termsGenerated": 7, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "openai-first", "userTier": "free", "topicName": "strength training", "factsGenerated": 4, "processingTime": 15980, "termsGenerated": 7}	2025-09-10 22:18:12.735
0986978f-1c25-49fa-9fcc-84659e5d8229	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 4, "numTerms": 7, "pipeline": "source-first", "userTier": "free", "topicName": "strength training"}	2025-09-10 22:22:19.76
87803e42-417c-4fd8-bf3d-b08f099d6754	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0054475, "jobId": "gen-1757542939729-hjmhx86vl", "model": "gpt-4o", "topic": "strength training", "totalTokens": 1148, "promptTokens": 382, "completionTokens": 766}}	2025-09-10 22:22:40.749
48a48107-b10f-4ba5-9005-0dbea598be1b	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 4, "processingTime": 21032, "termsGenerated": 7, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "strength training", "factsGenerated": 4, "processingTime": 21032, "termsGenerated": 7}	2025-09-10 22:22:40.763
699c30ca-f4b7-4fb3-b30b-d6ab22cd0f8b	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 20, "numTerms": 50, "pipeline": "source-first", "userTier": "free", "topicName": "strength training"}	2025-09-10 22:25:24.93
e69abd06-173e-4fe9-a08e-f07f0bf131f9	content_generation	\N	\N	\N	Content generation failed: failed	{"error": "Invalid JSON response from OpenAI", "event": "failed", "status": "failed", "pipeline": "source-first", "userTier": "free", "topicName": "strength training", "processingTime": 74405}	2025-09-10 22:26:39.323
51b0e81b-5a51-459d-b996-2c1c5b7dba05	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 20, "pipeline": "source-first", "userTier": "free", "topicName": "strength training"}	2025-09-10 22:28:42.492
ed7c216f-0a51-4453-a47e-be60ec0324d0	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.0115725, "jobId": "gen-1757543322467-4860g1smk", "model": "gpt-4o", "topic": "strength training", "totalTokens": 2437, "promptTokens": 382, "completionTokens": 2055}}	2025-09-10 22:29:06.031
f4790440-0f7a-4b81-b5fe-2e4775f383d1	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 10, "processingTime": 23569, "termsGenerated": 19, "duplicatesRemoved": 1, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "strength training", "factsGenerated": 10, "processingTime": 23569, "termsGenerated": 19}	2025-09-10 22:29:06.042
c5eb6bb0-6c28-45b6-a252-d4d652f52926	content_generation	\N	\N	\N	Content generation started: started	{"event": "started", "status": "started", "numFacts": 10, "numTerms": 20, "pipeline": "source-first", "userTier": "free", "topicName": "strength training"}	2025-09-10 22:30:11.373
49823f15-c57f-4688-a2bd-e1bb0cf5b01f	openai	\N	\N	\N	OpenAI request: [object Object] using undefined	{"promptType": {"cost": 0.019065, "jobId": "gen-1757543411370-m0p7lplei", "model": "gpt-4o", "topic": "strength training", "totalTokens": 4015, "promptTokens": 403, "completionTokens": 3612}}	2025-09-10 22:31:32.034
17cc4947-eacb-476f-a1a5-6af3f6dfbe3e	content_generation	\N	\N	\N	Content generation completed: completed	{"event": "completed", "stats": {"factsGenerated": 10, "processingTime": 80671, "termsGenerated": 20, "duplicatesRemoved": 0, "lowConfidenceTerms": 0}, "status": "completed", "pipeline": "source-first", "userTier": "free", "topicName": "strength training", "factsGenerated": 10, "processingTime": 80671, "termsGenerated": 20}	2025-09-10 22:31:32.043
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, "topicId", "canonicalSetId", term, definition, example, source, "sourceUrl", verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "createdAt", "moderationNote", "moderationStatus", "updatedAt", "updatedByAdmin") FROM stdin;
2c71d355-c9af-4b3f-9c26-8e17a902b896	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	deuce	Deuce, Deuces, or The Deuce may refer to:...	The game went to deuce four times before he finally won.	Wikipedia	https://en.wikipedia.org/wiki/Deuce	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
bcd10a1d-7e8f-475c-84f2-3d4d16fcaeca	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	lob	Lob may refer to:...	He hit a perfect lob that landed just inside the baseline.	Wikipedia	https://en.wikipedia.org/wiki/Lob	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
b79483a6-2ce6-4a45-8a27-afd9c3ad5865	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	match point	Match point may refer to:Match point (tennis), won if the player in the lead scores\nMatchpoint scoring, in duplicate bridge\nMatch Point, a 2005 film directed by Woody Allen\nMatchpoint , a 1990 British...	He served an ace on match point to win the tournament.	Wikipedia	https://en.wikipedia.org/wiki/Match_point	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
1fd1bccb-24cd-4e4d-b73d-db2727eb206e	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	rally	Rally or rallye may refer to:...	They had a long rally before he finally hit the ball out.	Wikipedia	https://en.wikipedia.org/wiki/Rally	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
7cff1b6e-044c-45e5-b372-89f806b3b9d5	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	serve	Serve or SERVE may refer to:...	He has one of the fastest serves in the game.	Wikipedia	https://en.wikipedia.org/wiki/Serve	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
1c573840-f7b4-4c56-a935-9e6b6ed1fe96	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	slice	Slice may refer to:Cutting...	He used a slice to make the ball skid and stay low.	Wikipedia	https://en.wikipedia.org/wiki/Slice	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
ac6ee759-bc58-4f74-9a26-17bd85cf0e4d	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	volley	Volley or Volly may refer to:...	She hit a winning volley at the net.	Wikipedia	https://en.wikipedia.org/wiki/Volley	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
f35cdfa1-c8a1-4579-969a-c760d106db26	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	break point	Tennis is a racket sport that is played either individually against a single opponent (singles) or between two teams of two players each (doubles). Each player uses a tennis racket strung with a cord ...	He capitalized on his opponent's double fault and won the break point.	Wikipedia	https://en.wikipedia.org/wiki/Tennis	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
a5eccc4b-a55a-421e-9745-f383122dc383	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	grand slam	Grand Slam or Grand slam may refer to:...	Winning a Grand Slam is the dream of every professional tennis player.	Wikipedia	https://en.wikipedia.org/wiki/Grand_Slam	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
161f8b02-dc90-4461-932d-dc141b40ee29	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	let	Let or LET may refer to:...	The serve was a let, so he had another chance to serve.	Wikipedia	https://en.wikipedia.org/wiki/Let	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
8401ffb4-176d-412e-8f87-c947e66a3cc2	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	tiebreak	In games and sport, a tiebreaker or tiebreak is any method used to determine a winner or to rank participants when there is a tie - meaning two or more parties have achieved a same score or result. A ...	They had to go into a tiebreak to decide the winner of the set.	Wikipedia	https://en.wikipedia.org/wiki/Tiebreaker	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
18f947cf-8b83-4016-b5ba-9e171a84113c	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	unforced error	\nThis page is a glossary of tennis terminology....	His unforced errors cost him the match.	Wikipedia	https://en.wikipedia.org/wiki/Glossary_of_tennis_terms	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	\N	pending	2025-09-09 00:09:21.284	f
cb979ed6-59cd-485f-a0e0-edfa332f8018	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	anime	Anime  is hand-drawn and computer-generated animation originating from Japan. Outside Japan and in English, anime refers specifically to animation produced in Japan. However, anime, in Japan and in Ja...	'Naruto' and 'Dragon Ball' are popular examples of anime.	Wikipedia	https://en.wikipedia.org/wiki/Anime	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
ed26cbc7-fac4-44f1-8cec-42f881765edb	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	manga	Manga  are comics or graphic novels originating from Japan. Most manga conform to a style developed in Japan in the late 19th century, and the form has a long history in earlier Japanese art. The term...	'Attack on Titan' was originally a manga before being adapted into an anime.	Wikipedia	https://en.wikipedia.org/wiki/Manga	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
b7f6ba16-6ad4-4b3c-86e2-633813827ff4	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	otaku	Otaku  is a type of Japanese subculture of people with consuming interests, such as anime, manga, video games, computers, or any other enthusiastically pursued hobby. Its contemporary use originated w...	John, being an otaku, has a vast collection of anime and manga.	Wikipedia	https://en.wikipedia.org/wiki/Otaku	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
ceb66675-4906-427a-a27d-94e80e6bb4c5	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	double fault	On the x86 architecture, a double fault exception occurs if the processor encounters a problem while trying to service a pending interrupt or exception. An example situation when a double fault would ...	Her double fault cost her the game.	Wikipedia	https://en.wikipedia.org/wiki/Double_fault	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	doesn't have to do with tennis 	rejected	2025-09-09 00:30:46.192	t
5c98e988-1cfa-4551-8dc5-f34549dc1e2e	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	baseline	A baseline is a line that is a base for measurement or for construction....	The player hit the ball just inside the baseline.	Wikipedia	https://en.wikipedia.org/wiki/Baseline	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	this definition isn't related to tennis	rejected	2025-09-09 03:18:45.85	t
83ed027f-3786-4d68-b66e-b81070db41b5	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	cosplay	Cosplay, a blend word of "costume play", is an activity and performance art in which participants called cosplayers wear costumes and fashion accessories to represent a specific character. Cosplayers ...	Many fans enjoy cosplay at anime conventions, embodying their favorite characters.	Wikipedia	https://en.wikipedia.org/wiki/Cosplay	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
72066772-ad26-4d62-9684-7e5ddf91967b	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	shnen	A genre of anime and manga aimed at young boys, often featuring action, adventure, and fighting.	'One Piece' is a well-known shōnen anime.	AI Generated	\N	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
3de755f9-3a5e-4bde-9f96-a2f904f5f22d	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	shjo	A genre of anime and manga aimed at young girls, usually featuring romance and relationships.	'Sailor Moon' is a classic shōjo anime.	AI Generated	\N	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
8cdc186c-b589-4726-967e-180e75ac1bcf	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	seiyuu	Voice acting in Japan is an industry where actors provide voice-overs as characters or narrators in media including anime, video games, audio dramas, commercials, and dubbing for non-Japanese films an...	Popular seiyuu Mamoru Miyano is known for his role in 'Death Note'.	Wikipedia	https://en.wikipedia.org/wiki/Voice_acting_in_Japan	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
c9a15547-dd74-4876-b797-00f3fd17144c	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	hentai	Hentai is a style of Japanese pornographic anime and manga. In addition to anime and manga, hentai works exist in a variety of media, including artwork and video games....	Hentai is a controversial genre within the anime community due to its explicit nature.	Wikipedia	https://en.wikipedia.org/wiki/Hentai	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
01dd1af7-7a3d-4d11-9bd8-80e8e1be3e60	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	chibi	Chibi most often refers to:Chibi (style), a super-deformed diminutive style of Japanese-influenced art, typically with big heads and small bodies.\nChibi, Hubei, a county-level city in southeastern Hub...	Chibi versions of anime characters are often used in promotional materials or merchandise.	Wikipedia	https://en.wikipedia.org/wiki/Chibi	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
cf52dca9-bce6-4d0d-b5e5-64b257760d3d	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	amv	AMV may refer to:...	AMVs are a popular way for fans to express their love for an anime series or pairing.	Wikipedia	https://en.wikipedia.org/wiki/AMV	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
4615b107-e752-45fd-9373-1ff2d3b6c71d	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	ova	The egg cell or ovum is the female reproductive cell, or gamete, in most anisogamous organisms. The term is used when the female gamete is not capable of movement (non-motile). If the male gamete (spe...	'Hellsing Ultimate' is an example of an OVA series.	Wikipedia	https://en.wikipedia.org/wiki/Egg_cell	f	t	0.5	general	beginner	2025-09-08 22:26:24.983	\N	pending	2025-09-09 00:09:21.284	f
16511af9-9b37-4936-a074-fe4a914a9a86	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	kawaii	Kawaii is a Japanese cultural phenomenon which emphasizes cuteness, childlike innocence, charm, and simplicity. Kawaii culture began to flourish in the 1970s, driven by youth culture and the rise of c...	The 'Hello Kitty' franchise is a perfect example of the kawaii aesthetic.	Wikipedia	https://en.wikipedia.org/wiki/Kawaii	f	t	0.5	general	beginner	2025-09-08 22:26:34.677	\N	pending	2025-09-09 00:09:21.284	f
f98298e2-a1f2-4937-8087-41888ed2bfb1	535e5d75-e346-4f2b-9522-095f7b452646	59952848-6ca4-41fb-a59a-e05228cf9f06	mecha	In science fiction, mecha  or mechs are giant robots or machines, typically depicted as piloted, humanoid walking vehicles. The term was first used in Japanese after shortening the English loanword 'm...	'Gundam' and 'Neon Genesis Evangelion' are popular examples of mecha anime.	Wikipedia	https://en.wikipedia.org/wiki/Mecha	f	t	0.5	general	beginner	2025-09-08 22:26:34.677	\N	pending	2025-09-09 00:09:21.284	f
09efba7c-8d68-4059-8fdd-6b93ba1a82b2	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	samurai	Samurai  were members of the warrior class who served as retainers to lords in Japan prior to the Meiji era. Samurai existed from the late 12th century until their abolition in the late 1870s during t...	The samurai served their daimyo, or feudal lord, with absolute loyalty.	Wikipedia	https://en.wikipedia.org/wiki/Samurai	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
62e4a669-02c7-4254-9451-e75ebc5df382	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	bushido	Bushidō  is a Samurai moral code concerning samurai attitudes, behavior and lifestyle. Its origins date back to the Kamakura period, but it was formalized in the Edo period (1603–1868). There are mult...	Bushido, the way of the warrior, guided the samurai’s conduct in warfare and in peace.	Wikipedia	https://en.wikipedia.org/wiki/Bushido	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
73acfbeb-c28e-4e25-a143-bc612dfc8e94	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	katana	A katana  is a Japanese sword characterized by a curved, single-edged blade with a circular or squared guard and long grip to accommodate two hands. Developed later than the tachi, it was used by samu...	The samurai wielded his katana with skill and precision.	Wikipedia	https://en.wikipedia.org/wiki/Katana	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
79d5e0f9-3fd5-4106-96c9-76e263ad871f	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	seppuku	Seppuku , also called harakiri , is a form of Japanese ritualistic suicide by disembowelment. It was originally reserved for samurai in their code of honor, but was also practiced by other Japanese pe...	The disgraced samurai chose to commit seppuku rather than live with his failure.	Wikipedia	https://en.wikipedia.org/wiki/Seppuku	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
18c7a2a7-61f9-4546-a17e-b6dd7b5e77c0	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	daimyo	Daimyo  were powerful Japanese magnates, feudal lords who, from the 10th century to the early Meiji period in the middle 19th century, ruled most of Japan from their vast hereditary land holdings. The...	The daimyo was a powerful figure, controlling vast territories through his samurai retainers.	Wikipedia	https://en.wikipedia.org/wiki/Daimyo	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
f6dee2b4-6b80-4fa3-809b-f00349748aa0	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	ronin	In feudal Japan to early modern Japan (1185–1868), a rōnin was a samurai who had no lord or master and in some cases, had also severed all links with his family or clan. A samurai became a rōnin upon ...	The ronin wandered the countryside, offering his services as a warrior to the highest bidder.	Wikipedia	https://en.wikipedia.org/wiki/R%C5%8Dnin	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
b463dec6-2146-4634-a242-4867a2c8d875	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	shogun	Shogun , officially seii taishōgun , was the title of the military rulers of Japan during most of the period spanning from 1185 to 1868. Nominally appointed by the Emperor, shoguns were usually the de...	The shogun ruled Japan with an iron fist, directing the actions of the samurai under his command.	Wikipedia	https://en.wikipedia.org/wiki/Shogun	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
b78d809d-d3e7-40bb-ae87-ce023eddceed	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	hakama	Hakama  are a type of traditional Japanese clothing. Originally stemming from Ku, the trousers worn by members of the Chinese imperial court in the Sui and Tang dynasties, this style was adopted by th...	The samurai wore a hakama over his kimono as part of his formal dress.	Wikipedia	https://en.wikipedia.org/wiki/Hakama	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
049cfec2-7f31-41d0-91db-7ee71f0b4d68	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	kendo	Kendo  is a modern Japanese martial art, descended from kenjutsu, that uses bamboo swords (shinai) as well as protective armor (bōgu). It began as samurai warriors' customary swordsmanship exercises, ...	The samurai practiced kendo daily to hone his swordsmanship skills.	Wikipedia	https://en.wikipedia.org/wiki/Kendo	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
79a87018-f796-45e9-9849-f3dd0752d5fd	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	yumi	Yumi  is the Japanese term for a bow. As used in English, yumi refers more specifically to traditional Japanese asymmetrical bows, and includes the longer daikyū  and the shorter hankyū  used in the p...	The samurai trained with the yumi, becoming a skilled archer as well as a swordsman.	Wikipedia	https://en.wikipedia.org/wiki/Yumi	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
0c3a3a49-3ba7-4cad-bdad-137c432cd867	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	dojo	A dōjō  is a hall or place for immersive learning, experiential learning, or meditation. This is traditionally in the field of martial arts. The term literally means "place of the Way" in Japanese....	The samurai spent hours in the dojo, perfecting his martial arts techniques.	Wikipedia	https://en.wikipedia.org/wiki/Dojo	f	t	0.5	general	beginner	2025-09-08 22:29:27.493	\N	pending	2025-09-09 00:09:21.284	f
bfafdd1d-a4c2-40f6-91c7-bfc774da085d	05baa19e-4e92-4e17-b040-66ef9114f2b6	6f344c61-c746-439c-8697-542466270031	kabuto	Kabuto is a type of helmet first used by ancient Japanese warriors that, in later periods, became an important part of the traditional Japanese armour worn by the samurai class and their retainers in ...	A samurai's kabuto was often elaborately decorated with designs or symbols to signify his clan or family.	Wikipedia	https://en.wikipedia.org/wiki/Kabuto	f	t	0.5	general	beginner	2025-09-08 22:29:32.454	\N	pending	2025-09-09 00:09:21.284	f
8051691d-47fa-4a44-9e00-cf8efcd01f7d	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	dribble	In sports, dribbling is maneuvering a ball by one player while moving in a given direction, avoiding defenders' attempts to intercept the ball. A successful dribble will bring the ball past defenders ...	The point guard was able to dribble past his opponents with ease.	Wikipedia	https://en.wikipedia.org/wiki/Dribbling	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
5870cd1e-2f6b-43be-8acf-f0fb56077bd7	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	rebound	Rebound can refer to:...	The center player was excellent at getting rebounds.	Wikipedia	https://en.wikipedia.org/wiki/Rebound	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
491ba797-e590-41f1-a85b-96b2e8ed73f2	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	free throw	In basketball, free throws or foul shots are unopposed attempts to score points by shooting from behind the free-throw line, a line situated at the end of the restricted area. Free throws are generall...	He was awarded two free throws after being fouled while shooting.	Wikipedia	https://en.wikipedia.org/wiki/Free_throw	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
aea96ef4-8e31-4bdc-9593-c622534a08f1	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	layup	A layup in basketball is a two-point shot attempt made by leaping from below, "laying" the ball up near the basket, and using one hand to bounce it off the backboard and into the basket. The motion an...	The player made a quick layup after beating the defender.	Wikipedia	https://en.wikipedia.org/wiki/Layup	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
2dc59933-81c2-4940-825e-f793f20cbfaf	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	slam dunk	A slam dunk, also simply known as a dunk, is a type of basketball shot that is performed when a player jumps in the air, controls the ball above the horizontal plane of the rim, and shoves the ball di...	The crowd went wild after the player's impressive slam dunk.	Wikipedia	https://en.wikipedia.org/wiki/Slam_dunk	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
5c41fa0a-6ec9-4579-b42d-cfc59ec2e9c3	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	three-point shot	A three-point field goal is a field goal in a basketball game made from beyond the three-point line, a designated arc surrounding the basket. A successful attempt is worth three points, in contrast to...	The guard hit a crucial three-point shot in the last seconds of the game.	Wikipedia	https://en.wikipedia.org/wiki/Three-point_field_goal	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
9c2bfb72-4c97-474e-8ddc-f10607c3f5b5	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	foul	Foul may refer to:...	The player was called for a foul after hitting an opponent's arm while attempting to steal the ball.	Wikipedia	https://en.wikipedia.org/wiki/Foul	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
7477ef65-b4fc-4cbb-a794-cd21d846dfe2	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	block	Block or blocked may refer to:...	The center player made a fantastic block, preventing a sure basket.	Wikipedia	https://en.wikipedia.org/wiki/Block	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
afcb36d1-9095-49ab-98f0-3ae732e23c1c	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	assist	Assist or ASSIST may refer to:...	The point guard had ten assists in the game, demonstrating his great vision and passing skills.	Wikipedia	https://en.wikipedia.org/wiki/Assist	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
0656b427-530b-412e-a9a8-5c791494a876	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	traveling	Travel is the movement of people between distant geographical locations. Travel can be done by foot, bicycle, automobile, train, boat, bus, airplane, ship or other means, with or without luggage, and ...	The referee called traveling on the player who took three steps without dribbling.	Wikipedia	https://en.wikipedia.org/wiki/Travel	f	t	0.5	general	beginner	2025-09-08 22:42:28.937	\N	pending	2025-09-09 00:09:21.284	f
06718d21-8cf6-41c2-b52f-b3da646f3932	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	dribbling	In sports, dribbling is maneuvering a ball by one player while moving in a given direction, avoiding defenders' attempts to intercept the ball. A successful dribble will bring the ball past defenders ...	The point guard was skilled at dribbling the ball down the court.	Wikipedia	https://en.wikipedia.org/wiki/Dribbling	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
91995c84-9ade-432d-a198-296c77b8af06	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	alley-oop	In basketball, an alley-oop is an offensive play in which one player passes the ball near the basket to a teammate who jumps, catches the ball in mid-air and dunks or lays it in before touching the gr...	The crowd roared in excitement after the successful alley-oop play.	Wikipedia	https://en.wikipedia.org/wiki/Alley-oop	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
702de28e-d633-4549-89a0-1847f17d2c9d	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	double-double	In basketball, a double-double is a single-game performance in which a player accumulates ten or more in two of the following five statistical categories: points, rebounds, assists, steals, and blocke...	The player recorded a double-double with 20 points and 10 rebounds.	Wikipedia	https://en.wikipedia.org/wiki/Double-double	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
38c95ed3-6f72-452c-bca7-431193a86718	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	triple-double	In basketball, a double-double is a single-game performance in which a player accumulates ten or more in two of the following five statistical categories: points, rebounds, assists, steals, and blocke...	The player notched a triple-double with 18 points, 11 assists, and 10 rebounds.	Wikipedia	https://en.wikipedia.org/wiki/Double-double	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
bd7a13b0-4219-4786-bbfb-a2d30bb6e154	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	turnover	Turnover or turn over may refer to:...	The team's high number of turnovers led to their defeat.	Wikipedia	https://en.wikipedia.org/wiki/Turnover	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
7095abac-e118-40a6-b37f-bdfcca9918cc	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	zone defense	Zone defense is a type of defensive system, used in team sports, which is the alternative to man-to-man defense; instead of each player guarding a corresponding player on the other team, each defensiv...	The coach decided to implement a zone defense to counter the opponent's shooting strategy.	Wikipedia	https://en.wikipedia.org/wiki/Zone_defense	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
3fabc69c-74c6-416d-a40c-62ad975b5b6e	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	0e5bd29c-e049-4dce-9800-d094ae95b657	man-to-man defense	Man-to-man defense, or man defense, is a type of defensive system used in team sports such as American football, association football, basketball and netball, as in which each player is assigned to de...	The team switched to a man-to-man defense to apply more pressure on the opposing team's star player.	Wikipedia	https://en.wikipedia.org/wiki/Man-to-man_defense	f	t	0.5	general	beginner	2025-09-08 22:42:32.232	\N	pending	2025-09-09 00:09:21.284	f
b21780b7-9ba0-437d-a731-2d669f48aaeb	ff520332-6b7f-45bd-a749-ff31b44dd180	e8871648-d165-4df0-95e7-1c904f2e80e9	ace	An ace is a playing card, die or domino with a single pip. In the standard French deck, an ace has a single suit symbol located in the middle of the card, sometimes large and decorated, especially in ...	He scored an ace on his first serve.	Wikipedia	https://en.wikipedia.org/wiki/Ace	f	t	0.5	general	beginner	2025-09-08 21:42:30.33	This definition doesn't have to do with tennis	rejected	2025-09-09 00:30:14.537	t
ff657050-f530-463e-b159-bd9b40c9dd82	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	sommelier	A sommelier, chef de vin or wine steward, is a trained and knowledgeable wine professional, normally working in fine restaurants, who specializes in all aspects of wine service as well as wine and foo...	The sommelier at the restaurant helped us select a wine that perfectly complemented our meal.	Wikipedia	https://en.wikipedia.org/wiki/Sommelier	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
676bd3a4-95ce-48c8-9a32-d1b939c87d8e	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	viticulture	Viticulture, viniculture, or winegrowing is the cultivation and harvesting of grapes. It is a branch of the science of horticulture. While the native territory of Vitis vinifera, the common grape vine...	A knowledgeable sommelier often has a deep understanding of viticulture.	Wikipedia	https://en.wikipedia.org/wiki/Viticulture	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
7461b0ca-839b-42b1-81a2-0a6f0c843a11	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	enology	Oenology is the science and study of wine and winemaking. Oenology is distinct from viticulture, which is the science of the growing, cultivation, and harvesting of grapes. The English word oenology d...	The sommelier studied enology to better understand the wine's production process.	Wikipedia	https://en.wikipedia.org/wiki/Oenology	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
836b3a75-f787-4ae9-908e-218af77eb06a	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	tannins	Tannins are a class of astringent, polyphenolic biomolecules that bind to and precipitate proteins and various other organic compounds including amino acids and alkaloids. The term tannin is widely ap...	The sommelier described the wine as having robust tannins.	Wikipedia	https://en.wikipedia.org/wiki/Tannin	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
1ec116a0-a4d3-4528-a1e3-a113b247264f	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	decanting	Decantation is a process for the separation of mixtures of immiscible liquids or of a liquid and a solid mixture such as a suspension. The layer closer to the top of the container—the less dense of th...	The sommelier decided to decant the old vintage to enhance its flavors.	Wikipedia	https://en.wikipedia.org/wiki/Decantation	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
1855a29b-81ca-4e49-ab38-75306e7a4f42	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	terroir	Terroir is a French term used to describe the environmental factors that affect a crop's phenotype, including unique environment contexts, farming practices and a crop's specific growth habitat. Colle...	The sommelier explained the influence of terroir on the taste of the wine.	Wikipedia	https://en.wikipedia.org/wiki/Terroir	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
93aee58b-9222-4dcb-8391-efd16e91fd4f	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	vintage	In winemaking, vintage is the process of picking grapes to create wine. A vintage wine is one made from grapes that were all, or primarily, grown and harvested in a single specified year. In certain w...	The sommelier recommended a vintage from 2005, claiming it was a good year for the winery.	Wikipedia	https://en.wikipedia.org/wiki/Vintage	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
26a13eac-962b-4d4f-a693-c71c7f344796	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	corked	Cork taint is a broad term referring to an off-odor and off-flavor wine fault arising from the presence in the cork of aroma-intense compounds that are transferred into wine after bottling....	The sommelier quickly realized the wine was corked and promptly replaced the bottle.	Wikipedia	https://en.wikipedia.org/wiki/Cork_taint	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
3b5d4b02-4672-4ad6-b703-04d8fcfed352	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	cellar	Cellar may refer to:Basement\nRoot cellar\nSemi-basement\nStorm cellar\nWine cellar...	The sommelier managed the restaurant's wine cellar, ensuring the wines were stored correctly.	Wikipedia	https://en.wikipedia.org/wiki/Cellar	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
fd942ec0-b8ac-4edb-a48b-89943431493b	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	bouquet	Bouquet, a word of French origin, pronounced, may refer to:...	The sommelier described the bouquet of the wine, noting hints of cherry and tobacco.	Wikipedia	https://en.wikipedia.org/wiki/Bouquet	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
7b5856fa-42dc-4358-8561-0de5b571f18e	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	oenophile	Oenophilia, in the strictest sense, describes a disciplined devotion to wine, accompanying strict traditions of consumption and appreciation. In a general sense however, oenophilia simply refers to th...	The sommelier was not just a professional in his field, he was also a passionate oenophile.	Wikipedia	https://en.wikipedia.org/wiki/Oenophilia	f	t	0.5	general	beginner	2025-09-09 04:15:11.005	\N	pending	2025-09-09 04:15:11.005	f
d2fc6ac6-73dc-441f-91d5-ece4cb11b42d	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	vinification	Winemaking, wine-making, or vinification is the production of wine, starting with the selection of the fruit, its fermentation into alcohol, and the bottling of the finished liquid. The history of win...	The sommelier explained the vinification process to enhance our appreciation of the wine we were drinking.	Wikipedia	https://en.wikipedia.org/wiki/Winemaking	f	t	0.5	general	beginner	2025-09-09 04:15:12.984	\N	pending	2025-09-09 04:15:12.984	f
1c152352-2297-4129-821a-aba5f8f9bb45	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	blind tasting	In marketing, a blind taste test is often used as a tool for companies to compare their brand to another brand. For example, the Pepsi Challenge is a famous taste test that has been run by Pepsi since...	As a part of his sommelier certification, he had to participate in a blind tasting.	Wikipedia	https://en.wikipedia.org/wiki/Blind_taste_test	f	t	0.5	general	beginner	2025-09-09 04:15:12.984	\N	pending	2025-09-09 04:15:12.984	f
4d532395-bb4b-4769-94a0-b01345b04923	e0ef2673-97c9-410f-b371-9a1ee72680d6	1417e3e7-5f9f-48d8-8c97-abb58900409d	cellar management	The process of managing a wine storage area, including rotation, temperature control, and inventory.	The sommelier is responsible for cellar management to ensure the wines are stored under optimal conditions.	AI Generated	\N	f	t	0.5	general	beginner	2025-09-09 04:15:12.984	\N	pending	2025-09-09 04:15:12.984	f
09df9263-84fd-4e01-a7d7-f23d66f7e5b7	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	machine learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	Netflix uses machine learning algorithms to recommend movies to its users.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
2e05303b-db82-4f64-a3c0-aeb6a785c595	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	supervised learning	In machine learning, supervised learning (SL) is a type of machine learning paradigm where an algorithm learns to map input data to a specific output based on example input-output pairs. This process ...	Email spam filters use supervised learning to classify emails as 'spam' or 'not spam'.	Wikipedia	https://en.wikipedia.org/wiki/Supervised_learning	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
41d4560d-6c8b-4eb8-8a0a-ed460f6e92c2	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	unsupervised learning	Unsupervised learning is a framework in machine learning where, in contrast to supervised learning, algorithms learn patterns exclusively from unlabeled data. Other frameworks in the spectrum of super...	Unsupervised learning is used in market segmentation to group customers with similar behaviors.	Wikipedia	https://en.wikipedia.org/wiki/Unsupervised_learning	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
b78f8dd8-a86e-4b06-b272-99aa60605c3c	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	reinforcement learning	Reinforcement learning (RL) is an interdisciplinary area of machine learning and optimal control concerned with how an intelligent agent should take actions in a dynamic environment in order to maximi...	Reinforcement learning is used in self-driving cars to learn how to navigate roads.	Wikipedia	https://en.wikipedia.org/wiki/Reinforcement_learning	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
cd01074b-6de0-431c-a2da-de9d49568762	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	neural network	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Neural networks are used in image recognition software to identify objects in photos.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
3474ddfb-ebae-4171-9820-fc69620fdca2	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	deep learning	In machine learning, deep learning focuses on utilizing multilayered neural networks to perform tasks such as classification, regression, and representation learning. The field takes inspiration from ...	Deep learning is used in speech recognition systems like Siri and Alexa to understand and respond to voice commands.	Wikipedia	https://en.wikipedia.org/wiki/Deep_learning	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
dc973d05-d0ce-45e3-8c96-eee0de7bef9f	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	algorithm	In mathematics and computer science, an algorithm is a finite sequence of mathematically rigorous instructions, typically used to solve a class of specific problems or to perform a computation. Algori...	Google's search algorithm uses various factors to determine the order of search results.	Wikipedia	https://en.wikipedia.org/wiki/Algorithm	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
69eff00c-a49d-41f2-b89d-ed14b78691d6	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	overfitting	In mathematical modeling, overfitting is "the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit to additional data or predict...	An overfitted model may perform well on the training data but fail to predict accurately on new data.	Wikipedia	https://en.wikipedia.org/wiki/Overfitting	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
692a2f92-8b39-4ed5-b83a-f44e833baa37	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	underfitting	In mathematical modeling, overfitting is "the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit to additional data or predict...	An underfitted model may not capture important trends in the data, leading to inaccurate predictions.	Wikipedia	https://en.wikipedia.org/wiki/Overfitting	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
86d258b8-e69c-4739-86b5-b186485c2164	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	feature	Feature may refer to:...	In a machine learning model predicting house prices, features might include square footage, number of bedrooms, and location.	Wikipedia	https://en.wikipedia.org/wiki/Feature	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
50a2324d-6257-47ff-bf20-a659aff958cc	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	regression	Regression or regressions may refer to:...	Linear regression is used in machine learning to predict a continuous outcome variable (y) based on one or more predictor variables (x).	Wikipedia	https://en.wikipedia.org/wiki/Regression	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
4ffc724a-6f0d-449a-86bb-5c9dfcd47c05	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	classification	Classification is the activity of assigning objects to some pre-existing classes or categories. This is distinct from the task of establishing the classes themselves. Examples include diagnostic tests...	A machine learning model can be trained to classify emails into 'spam' or 'not spam'.	Wikipedia	https://en.wikipedia.org/wiki/Classification	f	t	0.5	general	beginner	2025-09-09 04:20:40.667	\N	pending	2025-09-09 04:20:40.667	f
7e76bc74-97b7-4bd0-bd99-04bcfc1769ed	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	training set	\nIn machine learning, a common task is the study and construction of algorithms that can learn from and make predictions on data. Such algorithms function by making data-driven predictions or decision...	In machine learning, 70% of the dataset might be used as the training set.	Wikipedia	https://en.wikipedia.org/wiki/Training%2C_validation%2C_and_test_data_sets	f	t	0.5	general	beginner	2025-09-09 04:20:42.373	\N	pending	2025-09-09 04:20:42.373	f
9d429d72-2aed-496b-a1c3-4e8b63a14597	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	b2b7a054-9e90-4f02-9f10-9350f3440fe9	test set	\nIn machine learning, a common task is the study and construction of algorithms that can learn from and make predictions on data. Such algorithms function by making data-driven predictions or decision...	After a machine learning model is trained, it's tested on the test set to evaluate its performance.	Wikipedia	https://en.wikipedia.org/wiki/Training%2C_validation%2C_and_test_data_sets	f	t	0.5	general	beginner	2025-09-09 04:20:42.373	\N	pending	2025-09-09 04:20:42.373	f
1055da07-480c-4fb4-92a5-7dcdc21357a3	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	pickleball	Pickleball is a racket or paddle sport in which two or four players use a smooth-faced paddle to hit a perforated, hollow plastic ball over a 34-inch-high (0.86 m) net. Pickleball is played indoors an...	Pickleball is a popular sport for all ages due to its easy-to-learn rules and engaging gameplay.	Wikipedia	https://en.wikipedia.org/wiki/Pickleball	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
c8c4e5e3-d16f-4259-ba9d-93a63dfb98bb	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	paddle	A paddle is a handheld tool with an elongated handle and a flat, widened end used as a lever to apply force onto the bladed end. It most commonly describes a completely handheld tool used to propel a ...	In pickleball, each player uses a paddle to hit the ball over the net.	Wikipedia	https://en.wikipedia.org/wiki/Paddle	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
72ee5363-5d25-4920-b1f5-39e7df48dc11	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	double bounce rule	\nThis glossary provides definitions and context for terminology related to, and jargon specific to, the sport of pickleball. Words or phrases in italics can be found on the list in their respective al...	The double bounce rule ensures that each team has a chance to set up before volleys begin.	Wikipedia	https://en.wikipedia.org/wiki/Glossary_of_pickleball	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
e84d0ef5-0f63-4c5a-b481-2a564c1eba7d	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	non-volley zone	\nThis glossary provides definitions and context for terminology related to, and jargon specific to, the sport of pickleball. Words or phrases in italics can be found on the list in their respective al...	If you step into the non-volley zone to hit a volley, you lose the point.	Wikipedia	https://en.wikipedia.org/wiki/Glossary_of_pickleball	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
1e5a5629-2d0b-40d5-843f-8d434cce38b4	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	volley	Volley or Volly may refer to:...	A well-timed volley can be a powerful move in pickleball.	Wikipedia	https://en.wikipedia.org/wiki/Volley	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
97bf0284-a40b-4d3d-bdf4-62ce176d9a47	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	serve	Serve or SERVE may refer to:...	In pickleball, the serve must be made underhand and diagonally towards the opponent's service court.	Wikipedia	https://en.wikipedia.org/wiki/Serve	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
136cd1a5-cf56-413b-8ba0-d5585f460cd5	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	dink	Dink or DINK may refer to:...	A good strategy in pickleball is to use a dink to force your opponent to move closer to the net.	Wikipedia	https://en.wikipedia.org/wiki/Dink	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
706b54a0-2212-4c6c-a33c-00d7f19753ff	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	rally	Rally or rallye may refer to:...	Long rallies can be both exhausting and exhilarating in a game of pickleball.	Wikipedia	https://en.wikipedia.org/wiki/Rally	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
a6f66042-659b-4763-bdcd-eb07e863847b	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	fault	Fault commonly refers to:Fault (geology), planar rock fractures showing evidence of relative movement\nFault (law), blameworthiness or responsibility...	If you hit the ball out of bounds in pickleball, it's considered a fault.	Wikipedia	https://en.wikipedia.org/wiki/Fault	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
94ea3390-73ec-4510-b53a-e68ee5107838	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	lob	Lob may refer to:...	A well-executed lob can give you time to regain your position in pickleball.	Wikipedia	https://en.wikipedia.org/wiki/Lob	f	t	0.5	general	beginner	2025-09-09 04:24:18.11	\N	pending	2025-09-09 04:24:18.11	f
b73eb59a-789a-49a0-8495-725c975290fa	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	kitchen	A kitchen is a room or part of a room used for cooking and food preparation in a dwelling or in a commercial establishment. A modern middle-class residential kitchen is typically equipped with a stove...	He stepped into the kitchen, violating the non-volley rule, and forfeited the point.	Wikipedia	https://en.wikipedia.org/wiki/Kitchen	f	t	0.5	general	beginner	2025-09-09 04:24:19.704	\N	pending	2025-09-09 04:24:19.704	f
1151f290-98f4-45a4-b042-151e3061d0fc	6299eb79-88f3-443f-b110-d14372c85985	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460	poach	Poaching is illegal hunting or fishing....	He decided to poach when he saw his partner wasn't in position to make a good shot.	Wikipedia	https://en.wikipedia.org/wiki/Poaching_(disambiguation)	f	t	0.5	general	beginner	2025-09-09 04:24:19.704	\N	pending	2025-09-09 04:24:19.704	f
caa31c76-a745-4f44-b4e4-932528bbbab2	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	artificial intelligence	Artificial intelligence (AI) is the capability of computational systems to perform tasks typically associated with human intelligence, such as learning, reasoning, problem-solving, perception, and dec...	Siri, Apple's voice assistant, is an example of Artificial Intelligence.	Wikipedia	https://en.wikipedia.org/wiki/Artificial_intelligence	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
4aff5d8d-f268-452f-b75d-59f37f356e01	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	machine learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	Netflix uses machine learning to recommend movies or shows to users based on their viewing history.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
83082fc8-c6c6-4752-9d5e-ffa42e38d928	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	deep learning	In machine learning, deep learning focuses on utilizing multilayered neural networks to perform tasks such as classification, regression, and representation learning. The field takes inspiration from ...	Deep learning is used in autonomous vehicles for object recognition and decision making.	Wikipedia	https://en.wikipedia.org/wiki/Deep_learning	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
92520c2b-f095-4483-bdfd-36f86b483bd5	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	neural network	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Neural networks are used in facial recognition technology.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
030b27ab-4d10-4afd-ad66-997bf33ef6cd	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	natural language processing	Natural language processing (NLP) is the processing of natural language information by a computer. The study of NLP, a subfield of computer science, is generally associated with artificial intelligenc...	Google Translate uses natural language processing to translate text from one language to another.	Wikipedia	https://en.wikipedia.org/wiki/Natural_language_processing	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
83d493c9-5337-4564-a04f-cc644b5fcb0a	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	cognitive computing	Cognitive computing refers to technology platforms that, broadly speaking, are based on the scientific disciplines of artificial intelligence and signal processing. These platforms encompass machine l...	IBM's Watson uses cognitive computing to understand and answer complex questions.	Wikipedia	https://en.wikipedia.org/wiki/Cognitive_computing	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
21f69e5a-f3a4-45ee-9a73-1574f10b52b2	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	algorithm	In mathematics and computer science, an algorithm is a finite sequence of mathematically rigorous instructions, typically used to solve a class of specific problems or to perform a computation. Algori...	Google's search engine uses complex algorithms to provide the most relevant search results.	Wikipedia	https://en.wikipedia.org/wiki/Algorithm	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
31f7358a-ba3b-48c0-adaa-c3a6af74420e	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	reinforcement learning	Reinforcement learning (RL) is an interdisciplinary area of machine learning and optimal control concerned with how an intelligent agent should take actions in a dynamic environment in order to maximi...	In reinforcement learning, a chess AI will learn optimal moves by playing many games and learning from its mistakes.	Wikipedia	https://en.wikipedia.org/wiki/Reinforcement_learning	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
8ddadb8c-10f2-408f-b130-45aa3024c0e4	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	supervised learning	In machine learning, supervised learning (SL) is a type of machine learning paradigm where an algorithm learns to map input data to a specific output based on example input-output pairs. This process ...	In supervised learning, a model might be trained to recognize cats by analyzing thousands of cat images.	Wikipedia	https://en.wikipedia.org/wiki/Supervised_learning	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
bc203124-9c3c-4829-9693-81e77eee4152	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	unsupervised learning	Unsupervised learning is a framework in machine learning where, in contrast to supervised learning, algorithms learn patterns exclusively from unlabeled data. Other frameworks in the spectrum of super...	Unsupervised learning might be used to segment customers into distinct groups based on purchasing behavior.	Wikipedia	https://en.wikipedia.org/wiki/Unsupervised_learning	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
74d64991-e038-49cd-ba33-291bcecdabf4	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	robotics	Robotics is the interdisciplinary study and practice of the design, construction, operation, and use of robots....	Boston Dynamics uses AI in robotics to create robots that can navigate complex terrains.	Wikipedia	https://en.wikipedia.org/wiki/Robotics	f	t	0.5	general	beginner	2025-09-09 04:42:38.998	\N	pending	2025-09-09 04:42:38.998	f
cb477c66-bec2-47a0-ad5d-76c42f4ad60c	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	neural networks	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Google's search algorithm uses neural networks to improve its search results.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	f	t	0.5	general	beginner	2025-09-09 04:42:43.494	\N	pending	2025-09-09 04:42:43.494	f
d1928766-b0fc-4c25-94fe-21cb04f5c1d4	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	1ea863f0-9d67-444e-b8a1-dd8523f42342	chatbot	A chatbot is a software application or web interface designed to have textual or spoken conversations. Modern chatbots are typically online and use generative artificial intelligence systems that are ...	Many customer service websites use chatbots to answer common questions and assist users.	Wikipedia	https://en.wikipedia.org/wiki/Chatbot	f	t	0.5	general	beginner	2025-09-09 04:42:43.494	\N	pending	2025-09-09 04:42:43.494	f
596ffd90-018d-42fd-98f5-bf8c02dadc6f	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum computing	A type of computation that uses quantum bits (qubits) to perform operations on data.	Quantum computing has the potential to solve problems that are currently intractable by classical computers.	AI Generated	\N	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
57ecb130-c67a-45db-b230-4ffa6c3f869a	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	qubit	In quantum computing, a qubit or quantum bit is a basic unit of quantum information—the quantum version of the classic binary bit physically realized with a two-state device. A qubit is a two-state qu...	A qubit can exist in a state of 0, 1, or both at the same time, due to the principle of superposition.	Wikipedia	https://en.wikipedia.org/wiki/Qubit	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
021ed6f6-bacb-480b-a046-70b401c06250	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	superposition	In mathematics, a linear combination or superposition is an expression constructed from a set of terms by multiplying each term by a constant and adding the results. The concept of linear combinations...	Superposition in a qubit means it can be both 0 and 1 at the same time.	Wikipedia	https://en.wikipedia.org/wiki/Linear_combination	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
8b78d42d-1283-4cb6-8fc2-5c45b5a76bd0	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum entanglement	Quantum entanglement is the phenomenon where the quantum state of each particle in a group cannot be described independently of the state of the others, even when the particles are separated by a larg...	Quantum entanglement allows qubits that are entangled to be in a superposition of states, resulting in a higher computational power.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_entanglement	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
1c9baeda-35aa-49b3-94ab-04e11dd22ebc	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum gate	\nIn quantum computing and specifically the quantum circuit model of computation, a quantum logic gate is a basic quantum circuit operating on a small number of qubits. Quantum logic gates are the buil...	Quantum gates manipulate an input of qubits into a different output state.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_logic_gate	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
a84d2c11-177a-4ed3-9006-3d6bed6946e6	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum algorithm	\n\nIn quantum computing, a quantum algorithm is an algorithm that runs on a realistic model of quantum computation, the most commonly used model being the quantum circuit model of computation. A classi...	Shor's algorithm is a famous quantum algorithm for factorizing large numbers.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_algorithm	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
9b2d566d-36a5-40d7-ae1a-2576a511a970	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum supremacy	In quantum computing, quantum supremacy or quantum advantage is the goal of demonstrating that a programmable quantum computer can solve a problem that no classical computer can solve in any feasible ...	Google claimed to have achieved quantum supremacy in 2019 with its 53-qubit quantum computer.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_supremacy	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
9d4b071b-958d-4651-af47-6a8414e364cc	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum state	In quantum physics, a quantum state is a mathematical entity that embodies the knowledge of a quantum system. Quantum mechanics specifies the construction, evolution, and measurement of a quantum stat...	A qubit is described by a quantum state that is a superposition of both 0 and 1.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_state	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
8ae636d7-0107-41f4-a95f-992db5136ef9	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	bell state	In quantum information science, the Bell's states or EPR pairs are specific quantum states of two qubits that represent the simplest examples of quantum entanglement. The Bell's states are a form of e...	Bell states are used in quantum teleportation and superdense coding.	Wikipedia	https://en.wikipedia.org/wiki/Bell_state	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
57fd3094-64e8-4c39-afd8-1686fb96cc5d	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum decoherence	Quantum decoherence is the loss of quantum coherence. It involves generally a loss of information of a system to its environment. Quantum decoherence has been studied to understand how quantum systems...	Quantum decoherence can result from interaction with the environment, leading to errors in quantum computation.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_decoherence	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
324e9a33-1bfc-47bf-b0d3-f68842f2d9c0	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	quantum circuit	In quantum information theory, a quantum circuit is a model for quantum computation, similar to classical circuits, in which a computation is a sequence of quantum gates, measurements, initializations...	Quantum circuits use qubits and quantum gates to perform operations.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_circuit	f	t	0.5	general	beginner	2025-09-09 04:42:47.595	\N	pending	2025-09-09 04:42:47.595	f
4b953352-15e5-4258-8416-6f8aefe7995e	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	blockchain	The blockchain is a distributed ledger with growing lists of records (blocks) that are securely linked together via cryptographic hashes. Each block contains a cryptographic hash of the previous block...	Bitcoin, the first successful cryptocurrency, operates on blockchain technology.	Wikipedia	https://en.wikipedia.org/wiki/Blockchain	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
d382dfd4-ec9c-4fb8-a059-c69f53b29662	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	decentralization	Decentralization or decentralisation is the process by which the activities of an organization, particularly those related to planning and decision-making, are distributed or delegated away from a cen...	Blockchain technology is built on the concept of decentralization, where no single entity has control over the entire network.	Wikipedia	https://en.wikipedia.org/wiki/Decentralization	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
3dffbd6c-52d3-4d13-8b7f-a4b007a3a575	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	cryptocurrency	A cryptocurrency is a digital currency designed to work through a computer network that is not reliant on any central authority, such as a government or bank, to uphold or maintain it. However, a type...	Bitcoin and Ethereum are popular types of cryptocurrency.	Wikipedia	https://en.wikipedia.org/wiki/Cryptocurrency	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
7f9b5314-3b8c-4f65-9198-2e8b931dff1e	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	smart contracts	\nA smart contract is a computer program or a transaction protocol that is intended to automatically execute, control or document events and actions according to the terms of a contract or an agreement...	Ethereum blockchain supports the use of smart contracts.	Wikipedia	https://en.wikipedia.org/wiki/Smart_contract	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
3c22a27e-44dd-4853-b496-6ae01a23d3a0	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	distributed ledger	A distributed ledger is a system whereby replicated, shared, and synchronized digital data is geographically spread (distributed) across many sites, countries, or institutions. Its fundamental rationa...	Blockchain is a type of distributed ledger.	Wikipedia	https://en.wikipedia.org/wiki/Distributed_ledger	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
29058e93-7c02-4555-9d63-1f6618c5d254	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	hashing	Hash, hashes, hash mark, or hashing may refer to:...	Hashing is a key part of creating a new block in a blockchain.	Wikipedia	https://en.wikipedia.org/wiki/Hash	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
baaa89e3-f45e-4638-9a22-9705f5542a9d	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	public key	Public-key cryptography, or asymmetric cryptography, is the field of cryptographic systems that use pairs of related keys. Each key pair consists of a public key and a corresponding private key. Key p...	In a blockchain transaction, the sender will need the recipient's public key.	Wikipedia	https://en.wikipedia.org/wiki/Public-key_cryptography	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
6882a6e7-ad65-4710-8236-a60d5c7d7884	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	private key	Public-key cryptography, or asymmetric cryptography, is the field of cryptographic systems that use pairs of related keys. Each key pair consists of a public key and a corresponding private key. Key p...	Keeping your private key secure is critical to maintain control over your cryptocurrency assets.	Wikipedia	https://en.wikipedia.org/wiki/Public-key_cryptography	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
28f13b65-32ac-4860-85a7-ec880cdc14ca	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	node	In general, a node is a localized swelling or a point of intersection....	Each node in a blockchain network independently verifies the transactions.	Wikipedia	https://en.wikipedia.org/wiki/Node	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
c1220e78-4ba2-4440-a458-1f06c7caf80c	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	mining	Mining is the extraction of valuable geological materials and minerals from the surface of the Earth. Mining is required to obtain most materials that cannot be grown through agricultural processes, o...	Bitcoin mining involves solving complex mathematical problems.	Wikipedia	https://en.wikipedia.org/wiki/Mining	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
4e70703b-278b-46f8-95b5-dbff04173462	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	proof of work	Proof of work is a form of cryptographic proof in which one party proves to others that a certain amount of a specific computational effort has been expended. Verifiers can subsequently confirm this e...	Bitcoin uses a proof of work system to validate transactions and create new blocks.	Wikipedia	https://en.wikipedia.org/wiki/Proof_of_work	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
6684d4bf-efd8-4ca4-bf8c-ba081881fa71	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	proof of stake	Proof-of-stake (PoS) protocols are a class of consensus mechanisms for blockchains that work by selecting validators in proportion to their quantity of holdings in the associated cryptocurrency. This ...	Ethereum is planning to switch from proof of work to proof of stake to increase its scalability.	Wikipedia	https://en.wikipedia.org/wiki/Proof_of_stake	f	t	0.5	general	beginner	2025-09-09 04:43:13.613	\N	pending	2025-09-09 04:43:13.613	f
ef66fc2c-7747-424f-8ace-202410d4d590	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	entanglement	Entanglement may refer to:Quantum entanglement\nOrientation entanglement\nEntanglement \nEntanglement of polymer chains, see Reptation\nWire entanglement\nin fishery: method by which fish are caught in fis...	In quantum computing, entanglement is used to link qubits, allowing for complex computations.	Wikipedia	https://en.wikipedia.org/wiki/Entanglement	f	t	0.5	general	beginner	2025-09-09 04:43:14.13	\N	pending	2025-09-09 04:43:14.13	f
c65cd9d8-747c-49fa-b2c3-7b31079298c7	2d06fa5d-b462-47d3-bdf0-ad76525993b6	065fd81f-279a-47fa-9590-74b90089a501	decoherence	Quantum decoherence is the loss of quantum coherence. It involves generally a loss of information of a system to its environment. Quantum decoherence has been studied to understand how quantum systems...	Decoherence is a major obstacle in the development of quantum computers because it leads to errors in calculations.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_decoherence	f	t	0.5	general	beginner	2025-09-09 04:43:14.13	\N	pending	2025-09-09 04:43:14.13	f
74c5cfdb-a5ea-4032-b4ca-0f98cef28660	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	cryptography	Cryptography, or cryptology, is the practice and study of techniques for secure communication in the presence of adversarial behavior. More generally, cryptography is about constructing and analyzing ...	Blockchain technology uses cryptography to ensure that transactions are secure and private.	Wikipedia	https://en.wikipedia.org/wiki/Cryptography	f	t	0.5	general	beginner	2025-09-09 04:43:33.28	\N	pending	2025-09-09 04:43:33.28	f
503210d5-87b0-4a73-810b-96aab5ff2bfc	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	smart contract	\nA smart contract is a computer program or a transaction protocol that is intended to automatically execute, control or document events and actions according to the terms of a contract or an agreement...	Ethereum, a blockchain platform, uses smart contracts to automate transactions.	Wikipedia	https://en.wikipedia.org/wiki/Smart_contract	f	t	0.5	general	beginner	2025-09-09 04:43:33.28	\N	pending	2025-09-09 04:43:33.28	f
ec11385a-8130-4db9-b2f6-683d32f477d7	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	wallet	A wallet is a flat case or pouch, often used to carry small personal items such as physical currency, debit cards, and credit cards; identification documents such as driving licence, identification ca...	A blockchain wallet allows users to manage different types of cryptocurrencies — like Bitcoin or Ethereum.	Wikipedia	https://en.wikipedia.org/wiki/Wallet	f	t	0.5	general	beginner	2025-09-09 04:43:33.28	\N	pending	2025-09-09 04:43:33.28	f
53498e9c-eda5-423b-8c22-bb732350c1be	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	fork	In cutlery or kitchenware, a fork is a utensil, now usually made of metal, whose long handle terminates in a head that branches into several narrow and often slightly curved tines with which one can s...	A hard fork in the Bitcoin blockchain created a new cryptocurrency called Bitcoin Cash.	Wikipedia	https://en.wikipedia.org/wiki/Fork	f	t	0.5	general	beginner	2025-09-09 04:43:33.28	\N	pending	2025-09-09 04:43:33.28	f
50a3a1d4-bba4-435b-b5f5-ecf8c90e66e1	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	permissioned blockchain	The blockchain is a distributed ledger with growing lists of records (blocks) that are securely linked together via cryptographic hashes. Each block contains a cryptographic hash of the previous block...	Some companies use permissioned blockchains to maintain control over who can access their network.	Wikipedia	https://en.wikipedia.org/wiki/Blockchain	f	t	0.5	general	beginner	2025-09-09 04:43:33.28	\N	pending	2025-09-09 04:43:33.28	f
4acdd69c-5d22-4193-9df6-4aefedde1272	e56556fd-4e45-4394-be3f-7e7d83a36367	68818923-e9ff-49cd-9f93-e7f5f007e560	public blockchain	The blockchain is a distributed ledger with growing lists of records (blocks) that are securely linked together via cryptographic hashes. Each block contains a cryptographic hash of the previous block...	Bitcoin and Ethereum are examples of public blockchains.	Wikipedia	https://en.wikipedia.org/wiki/Blockchain	f	t	0.5	general	beginner	2025-09-09 04:43:33.28	This is the definition for blockchain	rejected	2025-09-09 19:49:07.468	t
\.


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Topic" (id, name, "canonicalSetId") FROM stdin;
ff520332-6b7f-45bd-a749-ff31b44dd180	tennis	e8871648-d165-4df0-95e7-1c904f2e80e9
535e5d75-e346-4f2b-9522-095f7b452646	anime	59952848-6ca4-41fb-a59a-e05228cf9f06
05baa19e-4e92-4e17-b040-66ef9114f2b6	samurai	6f344c61-c746-439c-8697-542466270031
eab7a23d-a8df-4ea5-9d8d-834a426aaf29	basketball	0e5bd29c-e049-4dce-9800-d094ae95b657
e0ef2673-97c9-410f-b371-9a1ee72680d6	Sommelier	1417e3e7-5f9f-48d8-8c97-abb58900409d
82c29f46-8b67-479d-bfd6-4e7ffa08aa10	Machine Learning	b2b7a054-9e90-4f02-9f10-9350f3440fe9
6299eb79-88f3-443f-b110-d14372c85985	Pickle ball	9dfd9adc-d069-4a3c-b60f-e1df0f2bd460
cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	Artificial Intelligence	1ea863f0-9d67-444e-b8a1-dd8523f42342
2d06fa5d-b462-47d3-bdf0-ad76525993b6	Quantum Computing	065fd81f-279a-47fa-9590-74b90089a501
e56556fd-4e45-4394-be3f-7e7d83a36367	Blockchain Technology	68818923-e9ff-49cd-9f93-e7f5f007e560
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, subscription, "createdAt", "openAiFirstPreferred") FROM stdin;
ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	test@larry.com	free	2025-09-05 17:29:34.475	f
\.


--
-- Data for Name: UserQuota; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserQuota" (id, "userId", "currentUsage", "periodStart", "lastReset", "createdAt", "updatedAt") FROM stdin;
78d4c499-5e0e-4e4b-a0e7-f02c1def781e	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	3	2025-09-09 04:25:57.776	2025-09-09 04:25:57.776	2025-09-05 17:29:46.222	2025-09-09 04:31:02.308
\.


--
-- Data for Name: UserTopic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserTopic" (id, "userId", "topicId", weight) FROM stdin;
a24de36d-174f-4c73-863f-06ac41498a0f	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	ff520332-6b7f-45bd-a749-ff31b44dd180	100
68eaadad-d74b-487d-8ec6-1746a6080bf2	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	535e5d75-e346-4f2b-9522-095f7b452646	100
4dd2dd15-4bde-4649-ab74-57f1e0868afb	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	05baa19e-4e92-4e17-b040-66ef9114f2b6	100
46e617ef-7c3a-4aca-8a1b-b9fcbda2fc43	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	eab7a23d-a8df-4ea5-9d8d-834a426aaf29	100
c7d572bd-2d69-4df3-950f-5ba0b157d4df	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	e0ef2673-97c9-410f-b371-9a1ee72680d6	100
51ef0f7b-d28b-44db-9fe6-d44ae6ea73ab	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	82c29f46-8b67-479d-bfd6-4e7ffa08aa10	100
a937a2c6-f8f8-4516-b3bb-6325c29e3134	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	6299eb79-88f3-443f-b110-d14372c85985	100
16b68994-981b-403b-b046-519f14e55c04	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	cc2c4071-59d0-4cbc-bf04-ac3f2d8dca04	100
51a1a158-45de-443f-a793-a356a5ab34fc	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	2d06fa5d-b462-47d3-bdf0-ad76525993b6	100
5ae6c79e-db0a-491e-9a19-b21b57bde993	ba2ed75f-6d7c-4a6c-97d8-25bac01a90fe	e56556fd-4e45-4394-be3f-7e7d83a36367	100
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
85860666-4a80-42fb-865a-00a4f037a45a	8e2ff6e44db6a6e77c45cbfece6d9e32087c00cc7624af710a08cc7b519a56dc	2025-09-05 17:27:50.87221+00	20250901193144_super_api_migration	\N	\N	2025-09-05 17:27:50.850097+00	1
4f9e4090-0128-4728-8706-d3f7221e8cde	e22239f6ca919da58910c9f2609af0a84750c6cabeae347f95f6cf1f7ea40e2c	2025-09-05 17:27:50.88302+00	20250903062759_quota_add_migration	\N	\N	2025-09-05 17:27:50.874065+00	1
8429832f-a51a-4ac2-b7fa-9096a574889f	50c52370a6841cd655c485dcb07ca9356cad7bb39028e75ca1c3a0213526d160	2025-09-05 17:27:53.383175+00	20250905172753_add_unique_constraints	\N	\N	2025-09-05 17:27:53.374742+00	1
83d86764-1ce4-4a98-8187-019a0a28a283	0e7e677290e1e0b773f11c92b68644f0a9211ec9d14eb9bdcc2d18f3de6bc9d1	2025-09-09 00:09:21.325288+00	20250909000831_add_moderation_fields	\N	\N	2025-09-09 00:09:21.28222+00	1
4677e63d-7a62-45ce-835c-511efed302f3	9dad0a454230914d81813848d789a1825f5ff482c85c259d7a4cc6a8ebdda26e	2025-09-09 00:09:39.102777+00	20250909000939_moderation_migration	\N	\N	2025-09-09 00:09:39.100625+00	1
b4226c0e-d981-402d-9f4e-1d7b7a14d830	115ab475c10621b1579d9e535a9d21ca8b1e6dc5337048aa21a6c2aa4559046d	2025-09-09 03:24:40.662773+00	20250909032440_add_metric_log_table	\N	\N	2025-09-09 03:24:40.649649+00	1
d5adb701-26a8-4f68-91bc-8e73a3d43f7d	4a7d3e9bfe41205a2621c1ccc23825d57eb51a97cd871affd9736a9bf871b372	2025-09-10 20:29:35.732298+00	20250910202935_add_user_pipeline_preference	\N	\N	2025-09-10 20:29:35.7285+00	1
\.


--
-- Name: CanonicalSet CanonicalSet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."CanonicalSet"
    ADD CONSTRAINT "CanonicalSet_pkey" PRIMARY KEY (id);


--
-- Name: Fact Fact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_pkey" PRIMARY KEY (id);


--
-- Name: MetricLog MetricLog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MetricLog"
    ADD CONSTRAINT "MetricLog_pkey" PRIMARY KEY (id);


--
-- Name: Term Term_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_pkey" PRIMARY KEY (id);


--
-- Name: Topic Topic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_pkey" PRIMARY KEY (id);


--
-- Name: UserQuota UserQuota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserQuota"
    ADD CONSTRAINT "UserQuota_pkey" PRIMARY KEY (id);


--
-- Name: UserTopic UserTopic_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTopic"
    ADD CONSTRAINT "UserTopic_pkey" PRIMARY KEY (id);


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
-- Name: Fact_topicId_fact_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Fact_topicId_fact_key" ON public."Fact" USING btree ("topicId", fact);


--
-- Name: MetricLog_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MetricLog_createdAt_idx" ON public."MetricLog" USING btree ("createdAt");


--
-- Name: MetricLog_topicId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MetricLog_topicId_idx" ON public."MetricLog" USING btree ("topicId");


--
-- Name: MetricLog_type_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MetricLog_type_createdAt_idx" ON public."MetricLog" USING btree (type, "createdAt");


--
-- Name: MetricLog_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "MetricLog_type_idx" ON public."MetricLog" USING btree (type);


--
-- Name: Term_topicId_term_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "Term_topicId_term_key" ON public."Term" USING btree ("topicId", term);


--
-- Name: UserQuota_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "UserQuota_userId_idx" ON public."UserQuota" USING btree ("userId");


--
-- Name: UserQuota_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "UserQuota_userId_key" ON public."UserQuota" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Fact Fact_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: MetricLog MetricLog_factId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MetricLog"
    ADD CONSTRAINT "MetricLog_factId_fkey" FOREIGN KEY ("factId") REFERENCES public."Fact"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MetricLog MetricLog_termId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MetricLog"
    ADD CONSTRAINT "MetricLog_termId_fkey" FOREIGN KEY ("termId") REFERENCES public."Term"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: MetricLog MetricLog_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."MetricLog"
    ADD CONSTRAINT "MetricLog_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Term Term_canonicalSetId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_canonicalSetId_fkey" FOREIGN KEY ("canonicalSetId") REFERENCES public."CanonicalSet"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Term Term_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Term"
    ADD CONSTRAINT "Term_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Topic Topic_canonicalSetId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Topic"
    ADD CONSTRAINT "Topic_canonicalSetId_fkey" FOREIGN KEY ("canonicalSetId") REFERENCES public."CanonicalSet"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: UserQuota UserQuota_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserQuota"
    ADD CONSTRAINT "UserQuota_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: UserTopic UserTopic_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTopic"
    ADD CONSTRAINT "UserTopic_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UserTopic UserTopic_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."UserTopic"
    ADD CONSTRAINT "UserTopic_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict QSif9KoL2Ks1i3VNltcXmf7g8KGHZVGxJbtdFLRbnjkcrL16NmFJkXIav7EN3kT

