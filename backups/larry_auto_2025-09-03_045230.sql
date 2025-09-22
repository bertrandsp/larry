--
-- PostgreSQL database dump
--

\restrict skayAsv0K0cgpeWUA02X0fKlgCQLs5eN5Z4n5QFsh69A7yy8gEWT2SEt2Jmy9Qz

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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
\.


--
-- Data for Name: Fact; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Fact" (id, "topicId", fact, source, "sourceUrl", "gptGenerated", category, "createdAt") FROM stdin;
05bb5a78-dae3-486c-bb37-34430f3e1ba4	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	The concept of blockchain was first outlined in 1991 by Stuart Haber and W. Scott Stornetta, two researchers who wanted to implement a system where document timestamps could not be tampered with.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
409e3239-47e1-47ba-b3bc-e115570a5dd7	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain technology gained significant attention due to its application in Bitcoin, the first digital currency to solve the double spending problem without the need of a central authority or server.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
29d973ab-f0f8-4fb4-8c93-c73364890a39	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain transactions are secure, private, and efficient due to their decentralized nature.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
6e8d9276-1725-4f34-8a6f-0e1c0d081d4e	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	The global blockchain market size is expected to reach $20 billion by 2024.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
c6b78c29-78b9-41fb-8dd2-a3f9ebcea4aa	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Estonia is a global leader in blockchain technology, having implemented it for health, judicial, legislative, security and commercial code systems, with plans to extend its use to other spheres like personal medicine, cyber security and data embassies.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
661f91c8-99b9-4b21-bfd2-2c1f7fa3bef7	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	The world's first blockchain-based smartphone, named 'Finney', was created by Sirin Labs, and was launched in November 2018.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
fe635b87-52c6-4245-910b-fb99f6da5686	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain technology is not only used for financial transactions but also for a variety of applications such as supply chain management, digital voting, real estate, and healthcare records.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
c893873c-512e-4b41-8524-10b1ea714732	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	As of February 2022, the Bitcoin market cap is over $900 billion, making it the largest blockchain network.	AI Generated	\N	t	general	2025-09-03 03:55:33.317
\.


--
-- Data for Name: Term; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Term" (id, "topicId", "canonicalSetId", term, definition, example, source, "sourceUrl", verified, "gptGenerated", "confidenceScore", category, "complexityLevel", "createdAt") FROM stdin;
74cb0cbc-fb9c-4bd7-8836-ea3da3504b66	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Blockchain	The blockchain is a distributed ledger with growing lists of records (blocks) that are securely linked together via cryptographic hashes. Each block contains a cryptographic hash of the previous block...	Bitcoin uses blockchain technology to record transactions.	Wikipedia	https://en.wikipedia.org/wiki/Blockchain	t	f	1	general	advanced	2025-09-03 03:55:33.309
a75761b2-2f71-44d8-b5b6-dc24c6f9196c	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Cryptocurrency	A cryptocurrency is a digital currency designed to work through a computer network that is not reliant on any central authority, such as a government or bank, to uphold or maintain it. However, a type...	Bitcoin and Ethereum are examples of cryptocurrencies.	Wikipedia	https://en.wikipedia.org/wiki/Cryptocurrency	t	f	1	general	advanced	2025-09-03 03:55:33.309
8ff14690-bdc5-4223-8069-57a08d7aaf1d	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Decentralization	Decentralization or decentralisation is the process by which the activities of an organization, particularly those related to planning and decision-making, are distributed or delegated away from a cen...	Blockchain technology is often praised for its decentralization, which makes it resistant to control by any single entity.	Wikipedia	https://en.wikipedia.org/wiki/Decentralization	t	f	1	general	advanced	2025-09-03 03:55:33.309
2de1112b-5aad-4d8b-9a71-b8944ff523ad	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Smart Contract	\nA smart contract is a computer program or a transaction protocol that is intended to automatically execute, control or document events and actions according to the terms of a contract or an agreement...	Ethereum blockchain is known for its smart contract functionality.	Wikipedia	https://en.wikipedia.org/wiki/Smart_contract	t	f	1	general	advanced	2025-09-03 03:55:33.309
cbe8a057-e3ab-4834-a717-1b3e7e9a4f32	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Mining	Mining is the extraction of valuable geological materials and minerals from the surface of the Earth. Mining is required to obtain most materials that cannot be grown through agricultural processes, o...	Bitcoin mining involves solving complex mathematical problems to add a new block to the blockchain.	Wikipedia	https://en.wikipedia.org/wiki/Mining	t	f	1	general	advanced	2025-09-03 03:55:33.309
8f595b2e-f4e3-4983-923e-b54d652de9e8	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Block	Block or blocked may refer to:...	In the Bitcoin blockchain, a new block is added approximately every 10 minutes.	Wikipedia	https://en.wikipedia.org/wiki/Block	t	f	1	general	beginner	2025-09-03 03:55:33.309
cb3fb8b3-b130-48a5-93df-5e17cc9d215a	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Node	In general, a node is a localized swelling or a point of intersection....	In a decentralized blockchain, every node has a copy of the entire blockchain.	Wikipedia	https://en.wikipedia.org/wiki/Node	t	f	1	general	beginner	2025-09-03 03:55:33.309
12e27bcf-8575-45b5-89bb-b1cd372d0100	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Public Key	A cryptographic key that can be utilized by any party to encrypt a message. Another party can then receive the message and using a key that only they know (the private key), decode the message.	In blockchain, public keys are used as the addresses where transactions can be sent.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 03:55:33.309
d4372cd4-7905-4f94-a11e-a95fed045bc6	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Private Key	A secret key that is used in the decryption or creation of a digital signature.	In blockchain, a private key is used to sign transactions and access one's cryptocurrency holdings.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 03:55:33.309
7dcf733c-be8c-4b81-aab5-cb0fd5fbb265	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	\N	Hash	Hash, hashes, hash mark, or hashing may refer to:...	In blockchain, a cryptographic hash function is used to secure data.	Wikipedia	https://en.wikipedia.org/wiki/Hash	t	f	1	general	beginner	2025-09-03 03:55:33.309
\.


--
-- Data for Name: Topic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."Topic" (id, name, "canonicalSetId") FROM stdin;
7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine Learning	\N
04842c35-0266-43f1-9d72-85d9c54ba6b5	Artificial Intelligence	\N
6a141c53-2608-427e-b3a4-64957e874a60	Data Science	\N
cc553f3c-f717-44cc-af15-56baba255b3c	Web Development	\N
09f7c3d2-10f3-4fdc-aa4c-b0575fb0ed77	Cybersecurity	\N
f19f7ace-9c48-4f70-9c1e-fa7efdee222b	Blockchain	\N
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, subscription, "createdAt") FROM stdin;
0962645b-0daa-48fa-b0a7-f344d7b36919	pipeline-test@example.com	free	2025-09-01 19:36:04.025
b70d8284-9de4-4cee-af9a-3c437bf473d5	test-user-123@example.com	free	2025-09-01 19:39:13.211
\.


--
-- Data for Name: UserTopic; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."UserTopic" (id, "userId", "topicId", weight) FROM stdin;
abf1db6a-1f88-4f45-81b9-1538c9178492	0962645b-0daa-48fa-b0a7-f344d7b36919	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	75
0c5e3f07-e30f-42c8-93ea-ec1c095d2354	b70d8284-9de4-4cee-af9a-3c437bf473d5	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	75
21aaf50a-c6a6-429a-88af-e238e6f54ae4	b70d8284-9de4-4cee-af9a-3c437bf473d5	04842c35-0266-43f1-9d72-85d9c54ba6b5	80
4208dd47-a501-4b7f-b9a7-411da4b18410	b70d8284-9de4-4cee-af9a-3c437bf473d5	6a141c53-2608-427e-b3a4-64957e874a60	85
ab8dd854-a6b4-4c13-a8e4-450a687c0fe8	b70d8284-9de4-4cee-af9a-3c437bf473d5	cc553f3c-f717-44cc-af15-56baba255b3c	90
0abc1703-f5cd-42da-acd5-dd54380449db	b70d8284-9de4-4cee-af9a-3c437bf473d5	09f7c3d2-10f3-4fdc-aa4c-b0575fb0ed77	95
e4425860-8b91-4240-bd1e-e9bf19d9c9dc	b70d8284-9de4-4cee-af9a-3c437bf473d5	f19f7ace-9c48-4f70-9c1e-fa7efdee222b	100
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
1c11b7e4-d274-4649-8c1f-7d7c6783ec15	8e2ff6e44db6a6e77c45cbfece6d9e32087c00cc7624af710a08cc7b519a56dc	2025-09-01 19:31:44.414942+00	20250901193144_super_api_migration	\N	\N	2025-09-01 19:31:44.392497+00	1
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
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: Fact Fact_topicId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."Fact"
    ADD CONSTRAINT "Fact_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES public."Topic"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


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

\unrestrict skayAsv0K0cgpeWUA02X0fKlgCQLs5eN5Z4n5QFsh69A7yy8gEWT2SEt2Jmy9Qz

