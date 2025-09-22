--
-- PostgreSQL database dump
--

\restrict ahdks5lRCiVgLT0KxYCmcgBWVeop8qcu8HHFtbwaCwNWMUgYhhuT9w8tvashEsk

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
f558ff71-aacc-48ae-98ae-a1e762f43cb7	183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum computers could potentially solve certain complex problems much faster than the fastest supercomputers available today.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
2072a6a0-855d-4cec-96a9-ff53beb2036b	183e3db4-3b45-4017-9d95-ca93cf4ca582	The concept of quantum computing was first introduced by physicist Richard Feynman in 1982.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
ea8610ec-9bbf-4f16-82f2-dee5a147d2da	183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum computers do not use binary logic. Instead, they use the principles of quantum mechanics to process information.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
2043ebe5-6586-4c0f-863d-a5dd7ff831bb	183e3db4-3b45-4017-9d95-ca93cf4ca582	In 2019, Google announced that it had achieved 'quantum supremacy' with a 53-qubit quantum computer.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
1793e03f-862a-4262-98f9-4f10ef0ce077	183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum computers could revolutionize fields such as cryptography, material science, and artificial intelligence.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
d1f8e6c4-f47d-4509-bb49-fa60ef311195	183e3db4-3b45-4017-9d95-ca93cf4ca582	Currently, maintaining the stability of qubits is one of the biggest challenges in quantum computing.	AI Generated	\N	t	general	2025-09-03 05:30:19.282
de90f8a4-9b20-4eea-9a4b-7f10fbeb0a06	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	The concept of machine learning was first proposed by Arthur Samuel in 1959.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
405a998e-51ec-4dea-b773-4a3379eff842	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	One of the earliest applications of machine learning was in the game of checkers where a computer program learned to improve its performance by playing games against itself.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
139d93f9-0717-4b71-a0b6-238ce5a8138c	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine learning is used in a wide range of applications including email filtering, detection of network intruders, medical diagnosis, stock trading and speech recognition.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
620fc78b-24a5-40c3-97f7-83b1a7022784	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Deep learning, a subset of machine learning, is based on artificial neural networks which are designed to simulate the way the human brain works.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
45d91342-b454-4894-aa5d-1245495bc96b	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine learning algorithms can identify patterns in data and make predictions much faster and more accurately than humans can.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
65c7a5e0-51ba-4742-90a8-c5c22e031828	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	The increase in the amount of digital data available for analysis has been one of the main drivers of the recent growth in the use of machine learning.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
a7e1627c-c088-4384-a5aa-7a6f3a83de55	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine learning is an essential part of artificial intelligence (AI). It provides AI with the ability to learn, improvise and evolve with experience.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
95676bfa-374a-426d-a204-5f1db2c14673	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	Machine Learning is heavily used by search engines to improve their performance in delivering more accurate results.	AI Generated	\N	t	general	2025-09-03 05:43:04.414
9dc5d057-3a67-493b-9985-33c216fea30e	04842c35-0266-43f1-9d72-85d9c54ba6b5	The term 'Artificial Intelligence' was first coined by John McCarthy in 1956.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
5d7115a3-c13c-4aec-b577-266cb0b55b4c	04842c35-0266-43f1-9d72-85d9c54ba6b5	AI can be classified into two types: Narrow AI, which is designed to perform a narrow task (such as facial recognition or internet searches) and General AI, which can perform any intellectual task that a human being can do.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
cd7f8842-c7f9-4090-8cf2-6bdaf3f1306c	04842c35-0266-43f1-9d72-85d9c54ba6b5	Artificial Intelligence can work 24/7 without any breaks and it does not get bored unlike humans.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
be027a05-7244-467c-bad5-281f0b384459	04842c35-0266-43f1-9d72-85d9c54ba6b5	AI is being used in a wide variety of fields including healthcare, finance, transportation, and entertainment.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
3de802d3-f072-41f4-a4ef-6480d79f4d77	04842c35-0266-43f1-9d72-85d9c54ba6b5	As per the World Intellectual Property Organization, over half of the patent applications for AI technologies have been filed in the last five years.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
c0133742-2f44-4375-992e-17f4402cc55e	04842c35-0266-43f1-9d72-85d9c54ba6b5	A type of AI called 'Predictive AI' is being used to predict and prevent cyberattacks in real-time.	AI Generated	\N	t	general	2025-09-03 06:01:54.419
42fdf34b-4b3d-4dbb-8be1-c21405f505e4	cc553f3c-f717-44cc-af15-56baba255b3c	The first ever website was published on August 6, 1991 by British physicist Tim Berners-Lee.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
ce623003-09a4-42a2-83d8-d362f8847726	cc553f3c-f717-44cc-af15-56baba255b3c	JavaScript was created in just 10 days. In May 1995, Brendan Eich wrote the first version of JavaScript in 10 days while working at Netscape.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
9dca3dde-e1a3-4c6c-9091-cc1ab4aa04e9	cc553f3c-f717-44cc-af15-56baba255b3c	The 'www' part of a web address stands for 'World Wide Web' which is a term that represents the system we use to access the internet.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
1c9e439b-6ec1-4b39-8e91-a3dc1021c51f	cc553f3c-f717-44cc-af15-56baba255b3c	The original HTML, created by Tim Berners-Lee, had only 20 elements. Today's HTML5 has 140.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
95e0e2ff-9e7b-46d8-bdf5-539a0e966f75	cc553f3c-f717-44cc-af15-56baba255b3c	CSS was first proposed by Håkon Wium Lie on October 10, 1994. At the time, Lie was working with Tim Berners-Lee at CERN.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
c8d7fdcf-dae8-48be-8ce2-48ac70bff609	cc553f3c-f717-44cc-af15-56baba255b3c	As of January 2021, there are over 1.8 billion websites on the internet, although less than 200 million are active.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
9061bbaa-d9c5-41f0-85bc-6c3b6585d0e7	cc553f3c-f717-44cc-af15-56baba255b3c	The most popular content management system (CMS) for website building is WordPress, which powers over 35% of all the websites on the Internet.	AI Generated	\N	t	general	2025-09-03 06:04:52.378
6e54476e-521f-490e-86b7-c3ed8b5f93d1	6a141c53-2608-427e-b3a4-64957e874a60	Harvard Business Review named 'Data Scientist' the 'Sexiest Job of the 21st Century'.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
8c2b3c0b-9bf0-452e-bae4-a900845bc860	6a141c53-2608-427e-b3a4-64957e874a60	The term 'Data Science' has been around since the early 1960s and was first used by Peter Naur in 1960.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
bc9b45ec-2a70-4b9e-ab3d-509d63db97fb	6a141c53-2608-427e-b3a4-64957e874a60	By 2025, it's predicted that there will be 175 zettabytes (175 billion terabytes) of data worldwide, up from just 33 zettabytes in 2018.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
f694fde1-5a00-44ac-9ec6-f94c9184404a	6a141c53-2608-427e-b3a4-64957e874a60	Data scientists spend about 60% of their time cleaning and organizing data.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
2294038e-7b1c-467b-8d80-10834d685e20	6a141c53-2608-427e-b3a4-64957e874a60	In the United States, data scientists earn an average salary of $120,000 per year.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
83e17839-7563-4510-8861-bba187531d5e	6a141c53-2608-427e-b3a4-64957e874a60	Data science is applicable in various fields including healthcare, finance, retail, transport, and more.	AI Generated	\N	t	general	2025-09-03 06:07:30.469
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
37d9cf86-cccb-4d82-ae9e-0d11738ce48e	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Computing	A quantum computer is a computer that uses quantum mechanical phenomena in an essential way: it exploits superposed and entangled states, and the intrinsically non-deterministic outcomes of quantum me...	Quantum computing could potentially solve complex problems much faster than traditional computing.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_computing	t	f	1	general	advanced	2025-09-03 05:30:19.259
f8f5ddf0-3840-4e54-945c-f14e1683f0b9	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Qubit	In quantum computing, a qubit or quantum bit is a basic unit of quantum information—the quantum version of the classic binary bit physically realized with a two-state device. A qubit is a two-state qu...	A qubit can exist in a state of 0, 1, or both at the same time.	Wikipedia	https://en.wikipedia.org/wiki/Qubit	t	f	1	general	advanced	2025-09-03 05:30:19.259
e5df381b-d605-4249-847a-7d0c226bbf44	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Superposition	In mathematics, a linear combination or superposition is an expression constructed from a set of terms by multiplying each term by a constant and adding the results. The concept of linear combinations...	In quantum computing, a qubit can be in a state of superposition, existing as both 0 and 1 simultaneously.	Wikipedia	https://en.wikipedia.org/wiki/Linear_combination	t	f	1	general	advanced	2025-09-03 05:30:19.259
94101aea-51df-487e-a2cf-1bdccfa69529	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Entanglement	Entanglement may refer to:Quantum entanglement\nOrientation entanglement\nEntanglement \nEntanglement of polymer chains, see Reptation\nWire entanglement\nin fishery: method by which fish are caught in fis...	Quantum entanglement is a key principle that allows quantum computers to process massive amounts of data simultaneously.	Wikipedia	https://en.wikipedia.org/wiki/Entanglement	t	f	1	technique	advanced	2025-09-03 05:30:19.259
e7ce20de-44f9-490c-858d-5e5ba1d6aeed	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Circuit	A sequence of basic quantum gates or operations that are applied to qubits to perform a quantum computation.	The design of a quantum circuit is crucial for the efficient operation of a quantum computer.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 05:30:19.259
abf63738-6821-40ec-aa95-4d515811ecca	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Gate	\nIn quantum computing and specifically the quantum circuit model of computation, a quantum logic gate is a basic quantum circuit operating on a small number of qubits. Quantum logic gates are the buil...	Quantum gates manipulate the state of qubits and are used to perform quantum algorithms.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_logic_gate	t	f	1	general	advanced	2025-09-03 05:30:19.259
42150f7d-d03d-45bc-b273-c0cd4968e5d8	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Algorithm	A step-by-step procedure of quantum operations that can be performed on a quantum computer.	Shor's algorithm, a quantum algorithm, can factor large numbers more efficiently than classical computers.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 05:30:19.259
32cac6c5-aa99-4ae4-8f5e-02c560fb0803	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum Supremacy	Quantum Supremacy: How the Quantum Computer Revolution Will Change Everything is a non-fiction book by the American futurist and physicist Michio Kaku. The book, Kaku's eleventh, was initially publish...	In 2019, Google claimed to have achieved quantum supremacy with its Sycamore quantum processor.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_Supremacy	t	f	1	general	advanced	2025-09-03 05:30:19.259
14142a26-f243-4a16-afb1-fbe0803b1c87	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Quantum State	In quantum physics, a quantum state is a mathematical entity that embodies the knowledge of a quantum system. Quantum mechanics specifies the construction, evolution, and measurement of a quantum stat...	In quantum computing, computations are performed by manipulating the quantum state of the system.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_state	t	f	1	general	advanced	2025-09-03 05:30:19.259
e5a440a7-acff-4104-b664-8e9a0f215b06	183e3db4-3b45-4017-9d95-ca93cf4ca582	\N	Decoherence	Quantum decoherence is the loss of quantum coherence. It involves generally a loss of information of a system to its environment. Quantum decoherence has been studied to understand how quantum systems...	Decoherence is a major challenge in building practical quantum computers as it leads to errors in computations.	Wikipedia	https://en.wikipedia.org/wiki/Quantum_decoherence	t	f	1	general	advanced	2025-09-03 05:30:19.259
4505210d-8086-438d-84e4-13ca281b8237	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Machine Learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	Email spam filtering is an example of machine learning where the algorithm learns to classify emails as 'spam' or 'not spam'.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	t	f	1	general	advanced	2025-09-03 05:43:04.407
c56a8930-4213-48e2-9901-3891812a2ac6	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Supervised Learning	A type of machine learning where the model is trained on a labelled dataset. Each example in the dataset is a pair consisting of an input vector and a desired output value.	A supervised learning algorithm can be used to train a model that predicts house prices based on features like location, size, and condition.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 05:43:04.407
4043f04e-b3b5-4ce5-9c96-2a822cfa8196	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Unsupervised Learning	A type of machine learning where the model is trained on an unlabelled dataset and the goal is to find structure in the data.	Clustering is a common unsupervised learning task where the algorithm groups similar data together.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 05:43:04.407
8fb24fe3-d7f3-4f7b-bae0-55acc45e4c98	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Reinforcement Learning	Reinforcement learning (RL) is an interdisciplinary area of machine learning and optimal control concerned with how an intelligent agent should take actions in a dynamic environment in order to maximi...	Reinforcement learning is used to train self-driving cars by rewarding the system for safe driving and penalizing it for dangerous actions.	Wikipedia	https://en.wikipedia.org/wiki/Reinforcement_learning	t	f	1	general	advanced	2025-09-03 05:43:04.407
5b0b228e-0045-4250-917d-af9ef73b0f3d	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Neural Networks	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Neural networks are used in image recognition systems to identify objects in a picture.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	t	f	1	general	advanced	2025-09-03 05:43:04.407
9c1c4a2d-d117-4b08-a399-6db437651ce2	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Deep Learning	In machine learning, deep learning focuses on utilizing multilayered neural networks to perform tasks such as classification, regression, and representation learning. The field takes inspiration from ...	Deep learning is used in speech recognition systems like Amazon's Alexa or Apple's Siri.	Wikipedia	https://en.wikipedia.org/wiki/Deep_learning	t	f	1	general	advanced	2025-09-03 05:43:04.407
806119a4-cac1-406e-bc36-575b2869dd89	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Regression	Regression or regressions may refer to:...	Linear regression is used to predict a person's weight based on their height.	Wikipedia	https://en.wikipedia.org/wiki/Regression	t	f	1	general	beginner	2025-09-03 05:43:04.407
fea0c0ba-7d66-4684-89bd-113f5a13f20a	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Classification	Classification is the activity of assigning objects to some pre-existing classes or categories. This is distinct from the task of establishing the classes themselves. Examples include diagnostic tests...	A classification algorithm can be used to identify whether an email is spam or not.	Wikipedia	https://en.wikipedia.org/wiki/Classification	t	f	1	general	advanced	2025-09-03 05:43:04.407
cfb0f2f5-a367-47cc-bb29-81a2053011db	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Overfitting	In mathematical modeling, overfitting is "the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit to additional data or predict...	A complex machine learning model may overfit if it has too many parameters relative to the number of observations.	Wikipedia	https://en.wikipedia.org/wiki/Overfitting	t	f	1	general	advanced	2025-09-03 05:43:04.407
046f217e-bba1-4a1c-bd9f-231a83cc5478	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Underfitting	In mathematical modeling, overfitting is "the production of an analysis that corresponds too closely or exactly to a particular set of data, and may therefore fail to fit to additional data or predict...	A linear model may underfit a dataset that has a non-linear relationship.	Wikipedia	https://en.wikipedia.org/wiki/Overfitting	t	f	1	general	advanced	2025-09-03 05:43:04.407
41cfc433-7a5d-4f4f-8f29-7d095c6fad37	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Feature Extraction	The process of transforming raw data into features that can be used to improve the performance of machine learning algorithms.	In image recognition, feature extraction may involve identifying shapes or textures in the image.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 05:43:04.407
a6bf1f8f-f5b3-4f63-90b2-e4dd2e73f811	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Dataset	A data set is a collection of data. In the case of tabular data, a data set corresponds to one or more database tables, where every column of a table represents a particular variable, and each row cor...	A dataset for a machine learning project might include information like age, gender, and income to predict credit risk.	Wikipedia	https://en.wikipedia.org/wiki/Data_set	t	f	1	general	advanced	2025-09-03 05:43:04.407
0adcf30f-232a-41f8-8f39-9ecedc82a828	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Model Training	The process of determining the best model, or the best parameters for a model, through iterative learning from data.	Model training involves using a machine learning algorithm to learn the relationships between independent and dependent variables.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 05:43:04.407
1d07fdd7-44d5-4a84-9455-04bfa6e37d66	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Prediction	A prediction or  forecast is a statement about a future event or about future data. Predictions are often, but not always, based upon experience or knowledge of forecasters. There is no universal agre...	After training a machine learning model on weather data, the prediction might be whether or not it will rain tomorrow.	Wikipedia	https://en.wikipedia.org/wiki/Prediction	t	f	1	general	advanced	2025-09-03 05:43:04.407
b74a7743-5b95-4629-aaa0-51191af4a021	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	\N	Hyperparameter	Hyperparameter may refer to:Hyperparameter \nHyperparameter \n\n...	The learning rate is a common hyperparameter that determines the step size at each iteration while moving toward a minimum of a loss function.	Wikipedia	https://en.wikipedia.org/wiki/Hyperparameter	t	f	1	general	advanced	2025-09-03 05:43:04.407
398c2308-12b7-45bf-8e4d-d6e3a35d0c68	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Artificial Intelligence (AI)	Artificial intelligence (AI) is the capability of computational systems to perform tasks typically associated with human intelligence, such as learning, reasoning, problem-solving, perception, and dec...	Siri, the virtual assistant on iPhones, is a form of artificial intelligence.	Wikipedia	https://en.wikipedia.org/wiki/Artificial_intelligence	t	f	1	general	advanced	2025-09-03 06:01:54.413
8c5b7d4c-3275-49be-9e66-277ecdeded21	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Machine Learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	Netflix uses machine learning algorithms to recommend movies based on a user's viewing history.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	t	f	1	general	advanced	2025-09-03 06:01:54.413
55f184e6-4205-46ab-96ab-5b06d4d9728d	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Neural Network	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	Neural networks are used in self-driving cars to make decisions based on various inputs.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	t	f	1	general	advanced	2025-09-03 06:01:54.413
9be26dfd-9889-4af0-83ba-da4abc3686c1	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Natural Language Processing (NLP)	The ability of a computer program to understand human language as it is spoken.	Google Translate uses natural language processing to translate sentences into different languages.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:01:54.413
54cd5c73-9d6a-4cb6-8031-9e699e126a66	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Deep Learning	In machine learning, deep learning focuses on utilizing multilayered neural networks to perform tasks such as classification, regression, and representation learning. The field takes inspiration from ...	Deep learning is used in voice recognition systems like Amazon's Alexa.	Wikipedia	https://en.wikipedia.org/wiki/Deep_learning	t	f	1	general	advanced	2025-09-03 06:01:54.413
2700320a-e57f-4753-97dd-e7226373d68f	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Reinforcement Learning	Reinforcement learning (RL) is an interdisciplinary area of machine learning and optimal control concerned with how an intelligent agent should take actions in a dynamic environment in order to maximi...	Reinforcement learning is used in training AI for video games to make optimal moves.	Wikipedia	https://en.wikipedia.org/wiki/Reinforcement_learning	t	f	1	general	advanced	2025-09-03 06:01:54.413
9825617c-fdd9-4259-b79a-a8cee88568cf	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Supervised Learning	A type of machine learning where the model is trained on labeled data.	In supervised learning, an email spam filter is trained with many example emails with their labels (spam or not spam).	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:01:54.413
5f21829a-4eda-403d-93bf-37603717aea6	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Unsupervised Learning	A type of machine learning algorithm used to draw inferences from datasets consisting of input data without labeled responses.	Unsupervised learning can be used to identify clusters of customers based on their purchasing behavior.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:01:54.413
bb22449a-c702-4a39-8334-5358668e9d53	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Algorithm	In mathematics and computer science, an algorithm is a finite sequence of mathematically rigorous instructions, typically used to solve a class of specific problems or to perform a computation. Algori...	Search engines use complex algorithms to retrieve and prioritize results.	Wikipedia	https://en.wikipedia.org/wiki/Algorithm	t	f	1	general	advanced	2025-09-03 06:01:54.413
99f19923-44e2-4319-a200-73e719ceb50a	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Data Mining	Data mining is the process of extracting and finding patterns in massive data sets involving methods at the intersection of machine learning, statistics, and database systems. Data mining is an interd...	Companies use data mining techniques to analyze customer data and develop targeted marketing strategies.	Wikipedia	https://en.wikipedia.org/wiki/Data_mining	t	f	1	technique	advanced	2025-09-03 06:01:54.413
dfc2ceaa-9115-473e-abae-424c96c89923	04842c35-0266-43f1-9d72-85d9c54ba6b5	\N	Robotics	Robotics is the interdisciplinary study and practice of the design, construction, operation, and use of robots....	Artificial intelligence is a crucial aspect of advanced robotics, allowing robots to interpret and respond to the world around them.	Wikipedia	https://en.wikipedia.org/wiki/Robotics	t	f	1	general	intermediate	2025-09-03 06:01:54.413
042610bf-6f9f-4268-9662-3e6de7fc3537	cc553f3c-f717-44cc-af15-56baba255b3c	\N	HTML	Hypertext Markup Language (HTML) is the standard markup language for documents designed to be displayed in a web browser. It defines the content and structure of web content. It is often assisted by t...	HTML elements are the building blocks of HTML pages.	Wikipedia	https://en.wikipedia.org/wiki/HTML	t	f	1	general	advanced	2025-09-03 06:04:52.37
79d5d5b6-5da4-4aa3-8694-4bdc7a0c7c72	cc553f3c-f717-44cc-af15-56baba255b3c	\N	CSS	Cascading Style Sheets (CSS) is a style sheet language used for specifying the presentation and styling of a document written in a markup language such as HTML or XML. CSS is a cornerstone technology ...	CSS is used to define styles for your web pages, including the design, layout and variations in display for different devices and screen sizes.	Wikipedia	https://en.wikipedia.org/wiki/CSS	t	f	1	general	advanced	2025-09-03 06:04:52.37
89d1982b-fbfe-408e-80ca-a07e06d19365	cc553f3c-f717-44cc-af15-56baba255b3c	\N	JavaScript	JavaScript (JS) is a programming language and core technology of the web platform, alongside HTML and CSS. Ninety-nine percent of websites on the World Wide Web use JavaScript on the client side for w...	JavaScript can update and change both HTML and CSS.	Wikipedia	https://en.wikipedia.org/wiki/JavaScript	t	f	1	general	advanced	2025-09-03 06:04:52.37
0c736f20-9aa6-48e6-9fc3-0faa1cd8af10	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Front-End	The client side of a web application, usually involving HTML, CSS, and JavaScript.	Front-end developers are responsible for the look and feel of a website.	AI Generated	\N	f	t	0.8	general	beginner	2025-09-03 06:04:52.37
c6086d39-0f2d-4279-9420-955b564f9760	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Back-End	The server-side of a web application, responsible for managing data within the database and serving that data to the front-end to be displayed.	Back-end developers usually write the web services and APIs used by front-end developers and mobile application developers.	AI Generated	\N	f	t	0.8	general	advanced	2025-09-03 06:04:52.37
136e86ce-5584-4677-8f46-cf9cab626ae3	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Responsive Web Design	Responsive web design (RWD) or responsive design is an approach to web design that aims to make web pages render well on a variety of devices and window or screen sizes from minimum to maximum display...	With responsive web design, your website will adjust to the screen size and orientation of the device it's being viewed on.	Wikipedia	https://en.wikipedia.org/wiki/Responsive_web_design	t	f	1	general	advanced	2025-09-03 06:04:52.37
d7b41349-5f58-491d-b97b-2abb1d3c0641	cc553f3c-f717-44cc-af15-56baba255b3c	\N	API	An application programming interface (API) is a connection between computers or between computer programs. It is a type of software interface, offering a service to other pieces of software. A documen...	Twitter's API allows developers to access and integrate Twitter's functionality into their own software or application.	Wikipedia	https://en.wikipedia.org/wiki/API	t	f	1	tool	advanced	2025-09-03 06:04:52.37
31416268-3d91-43eb-a7fe-1c6eba1935b4	cc553f3c-f717-44cc-af15-56baba255b3c	\N	MySQL	MySQL is an open-source relational database management system (RDBMS). Its name is a combination of "My", the name of co-founder Michael Widenius's daughter My, and "SQL", the acronym for Structured Q...	MySQL is widely used for web-based applications, online publishing and web development.	Wikipedia	https://en.wikipedia.org/wiki/MySQL	t	f	1	general	advanced	2025-09-03 06:04:52.37
be02516f-57c3-4241-abdc-3f6b6d518c04	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Bootstrap	Bootstrapping is a self-starting process that is supposed to proceed without external input....	Bootstrap provides ready-made design templates for web developers.	Wikipedia	https://en.wikipedia.org/wiki/Bootstrapping_(disambiguation)	t	f	1	general	beginner	2025-09-03 06:04:52.37
581a0eb7-b997-4214-b803-6ec23a3f30f2	cc553f3c-f717-44cc-af15-56baba255b3c	\N	Git	Git is a distributed version control software system that is capable of managing versions of source code or data. It is often used to control source code by programmers who are developing software col...	Git is used to manage various versions of a project, allowing multiple developers to work together on the same project without overwriting each other's changes.	Wikipedia	https://en.wikipedia.org/wiki/Git	t	f	1	tool	advanced	2025-09-03 06:04:52.37
254d234b-28e9-456f-b603-944df6d7c1fa	cc553f3c-f717-44cc-af15-56baba255b3c	\N	AJAX	Ajax is a set of web development techniques that uses various web technologies on the client-side to create asynchronous web applications. With Ajax, web applications can send and retrieve data from a...	With AJAX, web applications can send and retrieve data from a server asynchronously without interfering with the display and behavior of the existing page.	Wikipedia	https://en.wikipedia.org/wiki/Ajax_(programming)	t	f	1	general	advanced	2025-09-03 06:04:52.37
3f84f8f5-b0c0-47e4-a6a5-8c878e923ec2	6a141c53-2608-427e-b3a4-64957e874a60	\N	Big Data	Big data primarily refers to data sets that are too large or complex to be dealt with by traditional data-processing software. Data with many entries (rows) offer greater statistical power, while data...	In data science, big data is often used to predict buying patterns of customers.	Wikipedia	https://en.wikipedia.org/wiki/Big_data	t	f	1	tool	advanced	2025-09-03 06:07:30.461
c2572c61-7df5-4377-8298-5c4835659265	6a141c53-2608-427e-b3a4-64957e874a60	\N	Machine Learning	Machine learning (ML) is a field of study in artificial intelligence concerned with the development and study of statistical algorithms that can learn from data and generalise to unseen data, and thus...	In data science, machine learning algorithms can be used to predict future trends based on past data.	Wikipedia	https://en.wikipedia.org/wiki/Machine_learning	t	f	1	general	advanced	2025-09-03 06:07:30.461
538566c6-42a4-4456-83d5-a3a9c65363e1	6a141c53-2608-427e-b3a4-64957e874a60	\N	Data Mining	Data mining is the process of extracting and finding patterns in massive data sets involving methods at the intersection of machine learning, statistics, and database systems. Data mining is an interd...	Data mining techniques are used in data science to extract useful information from large datasets.	Wikipedia	https://en.wikipedia.org/wiki/Data_mining	t	f	1	technique	advanced	2025-09-03 06:07:30.461
22101650-d25d-4802-b0a8-d8d0180a70f5	6a141c53-2608-427e-b3a4-64957e874a60	\N	Predictive Analytics	Predictive analytics encompasses a variety of statistical techniques from data mining, predictive modeling, and machine learning that analyze current and historical facts to make predictions about fut...	Data science uses predictive analytics to forecast customer behavior, equipment failures, and other future events.	Wikipedia	https://en.wikipedia.org/wiki/Predictive_analytics	t	f	1	general	advanced	2025-09-03 06:07:30.461
84e3860b-f766-4de7-ac46-208dc7706d7b	6a141c53-2608-427e-b3a4-64957e874a60	\N	Data Visualization	Data and information visualization is the practice of designing and creating graphic or visual representations of quantitative and qualitative data and information with the help of static, dynamic or ...	In data science, data visualization is used to show patterns, trends, and correlations that might go unnoticed in text-based data.	Wikipedia	https://en.wikipedia.org/wiki/Data_and_information_visualization	t	f	1	general	advanced	2025-09-03 06:07:30.461
4895709f-e16d-4c8f-8a58-a817d2ce1230	6a141c53-2608-427e-b3a4-64957e874a60	\N	Data Cleaning	Data cleansing or data cleaning is the process of identifying and correcting corrupt, inaccurate, or irrelevant records from a dataset, table, or database. It involves detecting incomplete, incorrect,...	Data cleaning is a crucial step in data science to ensure the accuracy of the results.	Wikipedia	https://en.wikipedia.org/wiki/Data_cleansing	t	f	1	general	advanced	2025-09-03 06:07:30.461
fdd0fd3d-ae41-4912-bfa6-beb4023fd300	6a141c53-2608-427e-b3a4-64957e874a60	\N	Algorithm	In mathematics and computer science, an algorithm is a finite sequence of mathematically rigorous instructions, typically used to solve a class of specific problems or to perform a computation. Algori...	Data scientists use algorithms to analyze data, make predictions, and make decisions.	Wikipedia	https://en.wikipedia.org/wiki/Algorithm	t	f	1	general	advanced	2025-09-03 06:07:30.461
f82651c7-a7de-41f0-b18e-b648dad7f6da	6a141c53-2608-427e-b3a4-64957e874a60	\N	Regression	Regression or regressions may refer to:...	In data science, regression might be used to understand the impact of age, income, and diet (independent variables) on the likelihood of getting a certain disease (dependent variable).	Wikipedia	https://en.wikipedia.org/wiki/Regression	t	f	1	general	beginner	2025-09-03 06:07:30.461
75c3ceae-2de8-4b1a-984b-165cdec51920	6a141c53-2608-427e-b3a4-64957e874a60	\N	Classification	Classification is the activity of assigning objects to some pre-existing classes or categories. This is distinct from the task of establishing the classes themselves. Examples include diagnostic tests...	In data science, classification algorithms are used to predict or categorize discrete responses.	Wikipedia	https://en.wikipedia.org/wiki/Classification	t	f	1	general	advanced	2025-09-03 06:07:30.461
85b925a2-285c-4931-bd61-d9f1104c51fe	6a141c53-2608-427e-b3a4-64957e874a60	\N	Anomaly Detection	The identification of rare items, events or observations which raise suspicions by differing significantly from the majority of the data.	In data science, anomaly detection can be used for fraud detection or system health monitoring.	AI Generated	\N	f	t	0.8	general	intermediate	2025-09-03 06:07:30.461
de217bc1-cd25-4ccf-89e6-9ace1cc18a04	6a141c53-2608-427e-b3a4-64957e874a60	\N	Neural Networks	\n\nA neural network is a group of interconnected units called neurons that send signals to one another. Neurons can be either biological cells or signal pathways. While individual neurons are simple, m...	In data science, neural networks are used for tasks such as image recognition and speech recognition.	Wikipedia	https://en.wikipedia.org/wiki/Neural_network	t	f	1	general	advanced	2025-09-03 06:07:30.461
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
5ab2e86a-7c97-4918-b467-a5d8841f58b0	Sustainable Energy	\N
183e3db4-3b45-4017-9d95-ca93cf4ca582	Quantum Computing	\N
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."User" (id, email, subscription, "createdAt") FROM stdin;
0962645b-0daa-48fa-b0a7-f344d7b36919	pipeline-test@example.com	free	2025-09-01 19:36:04.025
b70d8284-9de4-4cee-af9a-3c437bf473d5	test-user-123@example.com	free	2025-09-01 19:39:13.211
e22ba5c4-75bc-481a-82e4-c72e43188e04	premium-test@example.com	premium	2025-09-03 05:59:27.529
0673cf4a-f954-48bd-8b66-916137169dbe	basic-test@example.com	basic	2025-09-03 06:04:04.648
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
748a7642-07c4-4b65-8fc2-058eac6d9b3a	b70d8284-9de4-4cee-af9a-3c437bf473d5	5ab2e86a-7c97-4918-b467-a5d8841f58b0	95
51873bd1-4656-471d-8004-0bf44ecdb459	b70d8284-9de4-4cee-af9a-3c437bf473d5	183e3db4-3b45-4017-9d95-ca93cf4ca582	90
7ecb33b8-beb1-4c9c-84a3-bfea5ebcbfd1	b70d8284-9de4-4cee-af9a-3c437bf473d5	7d8b0d27-1a8d-4aa6-919d-ab9ea624a81d	85
5b84cfce-1529-48a7-9b5f-cff23333794b	e22ba5c4-75bc-481a-82e4-c72e43188e04	04842c35-0266-43f1-9d72-85d9c54ba6b5	95
988df68e-6f96-45f7-a046-94728cedcce1	0673cf4a-f954-48bd-8b66-916137169dbe	cc553f3c-f717-44cc-af15-56baba255b3c	90
28efbdae-7d69-45db-8d55-a6871b201630	0673cf4a-f954-48bd-8b66-916137169dbe	6a141c53-2608-427e-b3a4-64957e874a60	85
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

\unrestrict ahdks5lRCiVgLT0KxYCmcgBWVeop8qcu8HHFtbwaCwNWMUgYhhuT9w8tvashEsk

