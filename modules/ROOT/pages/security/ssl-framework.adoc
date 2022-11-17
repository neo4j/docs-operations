[[ssl-framework]]
= SSL framework
:description: This section describes SSL/TLS integration for securing communication channels in Neo4j. 

Neo4j supports the securing of communication channels using standard SSL/TLS technology.

This section describes the following:

* xref:security/ssl-framework.adoc#ssl-introduction[Introduction]
* xref:security/ssl-framework.adoc#ssl-prerequisites[Prerequisites]
** xref:security/ssl-framework.adoc#ssl-java-configuration[Java configuration]
** xref:security/ssl-framework.adoc#ssl-certificates[Certificates]
* xref:security/ssl-framework.adoc#ssl-policy-define[Define SSL policies]
* xref:security/ssl-framework.adoc#ssl-policy-apply[Apply SSL policies]
* xref:security/ssl-framework.adoc#ssl-providers[Choosing an SSL provider]
* xref:security/ssl-framework.adoc#legacy-ssl-system[The legacy SSL system]
* xref:security/ssl-framework.adoc#ssl-terminology[Terminology]


[[ssl-introduction]]
== Introduction

SSL support is enabled by creating an SSL policy, which consists of an SSL certificate together with a set of parameters.
The policy is then applied to the communication channel(s) that you wish to secure.
The process is described in the following sections.

[CAUTION]
--
If Neo4j is started without any SSL policy definitions, it will default to the _legacy SSL system_.
Additionally, if no certificates are installed, the Neo4j process will automatically generate a self-signed SSL certificate and a private key in a default directory.
For details, refer to xref:security/ssl-framework.adoc#legacy-ssl-system[The legacy SSL system].
--


[[ssl-prerequisites]]
== Prerequisites


[discrete]
[[ssl-java-configuration]]
=== Java configuration

The Neo4j SSL framework uses strong cryptography which may need to be specifically enabled on your Java platform.
For example, see: http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html


[discrete]
[[ssl-certificates]]
=== Certificates

The instructions in this section assume that you have already acquired the required xref:security/ssl-framework.adoc#term-ssl-certificate[certificates].

All certificates must be in the `PEM` format, and they can be combined into one file.
The private key is also required to be in the `PEM` format.
Multi-host and wildcard certificates are supported.
Such certificates are required if Neo4j has been configured with multiple connectors that bind to different interfaces.


[[ssl-policy-define]]
== Define SSL policies

SSL policies are configured by assigning values to parameters of the following format:

`dbms.ssl.policy.<policy-name>.<setting-suffix>`

The `policy-name` is the name of the policy that you wish to define.

The basic valid values for `setting-suffix` are described below:

[options="header"]
|===
| Setting suffix       | Description                                                                           | Default value
| `base_directory`     | The base directory under which cryptographic objects are searched for by default.     | This is a mandatory setting.
| `private_key`        | The private key used for authenticating and securing this instance.                   | _private.key_
| `public_certificate` | A public certificate matching the private key signed by a Certificate Authority (CA). | _public.crt_
| `trusted_dir`        | A directory populated with certificates of trusted parties.
                         If configured, this must be an absolute path.
                         At the very minimum, this must contain this node's public certificate (_public.crt_). | _trusted_
| `revoked_dir`        | A directory populated with certificate revocation lists (CRLs).
                         If configured, this must be an absolute path.                                         | _revoked_
|===


[NOTE]
====
The public certificate must be duplicated.
One copy is to be placed into the `base_directory`, and the other copy is to be placed into the `trusted_dir`.
====

The only mandatory setting is the base directory defined by `dbms.ssl.policy.<policy-name>.base_directory`.
By defining the base directory, we tell Neo4j to define a policy with the name `<policy-name>`.
If no other settings for this policy have been defined, Neo4j will by default be looking for the private key and the certificate file inside the base directory, as well as two subdirectories called _trusted_ and _revoked_.
If other paths are preferred, all the default values can be overridden.

For security reasons, Neo4j will not attempt to automatically create any of these directories.
The creation of an SSL policy therefore requires the appropriate file system structure to be set up manually.
Note that the existence of the directories is mandatory, as well as the presence of the certificate file and the private key.
Ensure correct permissions are set on the private key, such that only the Neo4j user can read it.


.Define a policy
====

In this example we will define and create configuration for a policy called `example_policy`.
As the simplest configuration possible, we define the base directory for this policy in  _neo4j.conf_:

[source, properties]
----
dbms.ssl.policy.example_policy.base_directory=certificates/example_policy
----

Then create the mandatory directories:

[source, shell]
----
$neo4j-home> mkdir certificates/example_policy
$neo4j-home> mkdir certificates/example_policy/trusted
$neo4j-home> mkdir certificates/example_policy/revoked
----

Finally, place the files _private.key_ and _public.crt_ into the base directory, and place another copy of the _public.crt_ into the _trusted_ directory:

[source, shell]
----
$neo4j-home> cp /path/to/certs/private.key certificates/example_policy
$neo4j-home> cp /path/to/certs/public.crt certificates/example_policy
$neo4j-home> cp /path/to/certs/public.crt certificates/example_policy/trusted
----

We will have the following listings:

[source, shell]
----
$neo4j-home> ls certificates/example_policy
-r-------- ... private.key
-rw-r--r-- ... public.crt
drwxr-xr-x ... revoked
drwxr-xr-x ... trusted
$neo4j-home> ls certificates/example_policy/trusted
-rw-r--r-- ... public.crt
----
====

Additionally, the following parameters can be configured for a policy:

[options="header"]
|===
| Setting suffix           | Description                                                                       | Default
| `client_auth`            | Whether or not clients must be authenticated.
                             Setting this to `REQUIRE` effectively enables mutual authentication for servers.
                             Available values given to this setting are `NONE`, `OPTIONAL`, or `REQUIRE`.      | `REQUIRE`
| `ciphers`                | A list of ciphers which will be allowed during cipher negotiation.                | Java platform default allowed cipher suites
| `tls_versions`           | A list of TLS/SSL protocol versions which will be supported.                      | `TLSv1.2`
| `allow_key_generation`   | It is _strongly recommended_ to keep this parameter at its default value of `false`.
                             If set to `true`, it will enable the auto-generation of a _.key_/_.crt_ file pair on startup.
                             Additionally, the required directory structure will be generated automatically.   | `false`
| `trust_all`              | It is _strongly recommended_ to keep this parameter at its default value of `false`.
                             Setting it to `true` means "trust anyone" and essentially disables authentication.| `false`
| `verify_hostname`        | Enabling this setting will turn on client-side hostname verification.
                             After the client has received the servers public certificate, it will compare the
                             address it used against the certificate Common Name (CN) and Subject Alternative
                             Names (SAN) fields.
                             If the address used doesn't match those fields, the client will disconnect.       | `false`
|===

The combination of Neo4j and the Java platform will provide strong cipher suites and protocols.


[[ssl-policy-apply]]
== Apply SSL policies

The different xref:security/ssl-framework.adoc#term-ssl-channel[communication channels] can be secured independently from each other, using the configuration settings below:

[.compact]
`xref:reference/configuration-settings.adoc#config_bolt.ssl_policy[bolt.ssl_policy]`::
The policy to be used for Bolt client traffic.
`xref:reference/configuration-settings.adoc#config_https.ssl_policy[https.ssl_policy]`::
The policy to be used for HTTPS client traffic.
`xref:reference/configuration-settings.adoc#config_causal_clustering.ssl_policy[causal_clustering.ssl_policy]`::
The policy to be used for intra-cluster communication.
`xref:reference/configuration-settings.adoc#config_dbms.backup.ssl_policy[dbms.backup.ssl_policy]`::
The policy to be used for encrypting backup traffic.

.Apply an SSL policy
====
Assume that we have configured the policies listed below:

* One policy called `client_policy` for encryption of client traffic.
* One policy called `cluster_policy` for intra-cluster encryption.
* One policy called `backup_policy` for encrypting backup traffic.

The following example will configure the encryption accordingly:

[source, properties]
----
bolt.ssl_policy=client_policy
https.ssl_policy=client_policy
causal_clustering.ssl_policy=cluster_policy
dbms.backup.ssl_policy=backup_policy
----
====


[[ssl-providers]]
== Choosing an SSL provider

The secure networking in Neo4j is provided through the Netty library, which supports both the native JDK SSL provider as well as Netty-supported OpenSSL derivatives.

Follow these steps to utilize OpenSSL:

. Install a suitable dependency into the `plugins/` folder of Neo4j.
  Dependencies can be downloaded from https://netty.io/wiki/forked-tomcat-native.html.
. Set `xref:reference/configuration-settings.adoc#config_dbms.netty.ssl.provider[dbms.netty.ssl.provider]=OPENSSL`.

[NOTE]
Using OpenSSL can significantly improve performance, especially for AES-GCM-cryptos, e.g. TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256.


[[legacy-ssl-system]]
== The legacy SSL system

SSL support can also be provided for Bolt and HTTPS using the _legacy SSL system_.
The legacy system is expected to be deprecated at some point in the future, so it is recommended to use the xref:security/ssl-framework.adoc[standard SSL configuration] instead.

In order to configure the legacy SSL system with Neo4j, the private key and certificate files must be named _neo4j.key_ and _neo4j.cert_, respectively.
Note that the key should be unencrypted.
Place the files into the assigned directory.
The default is a directory named _certificates_, which is located in the _neo4j-home_ directory.
The directory can also be configured explicitly using xref:reference/configuration-settings.adoc#config_dbms.directories.certificates[dbms.directories.certificates] in _neo4j.conf_.

If started without any certificates installed, the Neo4j process will automatically generate a self-signed SSL certificate and a private key in the default directory.
Using auto-generation of self-signed SSL certificates will not work if Neo4j has been configured with multiple xref:configuration/connectors.adoc[connectors] that bind to different IP addresses.
If you need to use multiple IP addresses, please configure certificates manually and use multi-host or wildcard certificates instead.

The legacy policy is available in the SSL framework under the special `legacy` policy name, but it does not allow the full flexibility of the framework.
It is essentially equivalent to the following SSL policy definition:

[source, properties]
----
bolt.ssl_policy=legacy
https.ssl_policy=legacy

dbms.ssl.policy.legacy.base_directory=certificates
dbms.ssl.policy.legacy.private_key=neo4j.key
dbms.ssl.policy.legacy.public_certificate=neo4j.cert
dbms.ssl.policy.legacy.allow_key_generation=true
dbms.ssl.policy.legacy.client_auth=NONE
----

The HTTPS and Bolt servers do not support client authentication (a.k.a. _mutual authentication_).
As a result, `client_auth` has to be turned off explicitly by having `client_auth=NONE` while migrating HTTPS and Bolt servers to the new ssl policy.
When client authentication is disabled, values assigned to `trusted_dir`, `revoked_dir` or `trust_all` will be ignored as they are settings used in client authentication.

The `tls_versions` and `ciphers` settings are supported in HTTPS and Bolt servers.
The `legacy` policy defaults to the TLS versions and cipher suites supported by the Java platform.


[[ssl-terminology]]
== Terminology

The following terms are relevant to SSL support within Neo4j:

[.compact]
[[term-ssl-certificate-authority]]Certificate Authority (_CA_)::
A trusted entity that issues electronic documents that can verify the identity of a digital entity.
The term commonly refers to globally recognized CAs, but can also include internal CAs that are trusted inside of an organization.
The electronic documents are digital xref:security/ssl-framework.adoc#term-ssl-certificate[certificates].
They are an essential part of secure communication, and play an important part in the xref:security/ssl-framework.adoc#term-ssl-pki[Public Key Infrastructure].

[[term-ssl-certificate-revocation-list]]Certificate Revocation List (_CRL_)::
In the event of a certificate being compromised, that certificate can be revoked.
This is done by means of a list (located in one or several files) spelling out which certificates are revoked.
The CRL is always issued by the xref:security/ssl-framework.adoc#term-ssl-certificate-authority[CA] which issues the corresponding certificates.

[[term-ssl-cipher]]cipher::
An algorithm for performing encryption or decryption.
In the most general implementation of encryption of Neo4j communications, we make implicit use of ciphers that are included as part of the Java platform.
The configuration of the SSL framework also allows for the explicit declaration of allowed ciphers.

[[term-ssl-channel]]communication channel::
A means for communicating with the Neo4j database.
Available channels are:
* Bolt client traffic
* HTTPS client traffic
* intra-cluster communication
* backup traffic

[[term-ssl-cryptographic-objects]]cryptographic objects::
A term denoting the artifacts xref:security/ssl-framework.adoc#term-ssl-private-key[private keys], xref:security/ssl-framework.adoc#term-ssl-certificate[certificates] and xref:security/ssl-framework.adoc#term-ssl-certificate-revocation-list[CRLs].

[[term-ssl-configuration-parameters]]configuration parameters::
These are the parameters defined for a certain xref:security/ssl-framework.adoc#term-ssl-policy[ssl policy] in _neo4j.conf_.

[[term-ssl-certificate]]certificate::
SSL certificates are issued by a trusted xref:security/ssl-framework.adoc#term-ssl-certificate-authority[certificate authority (_CA_)].
The public key can be obtained and used by anyone to encrypt messages intended for a particular recipient.
The certificate is commonly stored in a file named _<file name>.crt_.
This is also referred to as the xref:security/ssl-framework.adoc#term-ssl-public-key[public key].

[[term-ssl-san]]SAN::
SAN is an acronym for _Subject Alternative Names_.
It is an extension to certificates that one can include optionally.
When presented with a certificate that includes SAN entries, it is recommended that the address of the host is checked against this field.
Verifying that the hostname matches the certificate SAN helps prevent attacks where a rogue machine has access to a valid key pair.

[[term-ssl]]SSL::
SSL is an acronym for _Secure Sockets Layer_, and is the predecessor of xref:security/ssl-framework.adoc#term-ssl-tls-protocol[TLS].
It is common to refer to SSL/TLS as just SSL.
However, the modern and secure version is TLS, and this is also the default in Neo4j.

[[term-ssl-policy]]SSL policy::
An SSL policy in Neo4j consists of a xref:security/ssl-framework.adoc#term-ssl-certificate[a digital certificate] and a set of configuration parameters defined in _neo4j.conf_.

[[term-ssl-private-key]]private key::
The private key ensures that encrypted messages can be deciphered only by the intended recipient.
The private key is commonly stored in a file named _<file name>.key_.
It is important to protect the private key to ensure the integrity of encrypted communication.

[[term-ssl-pki]]Public Key Infrastructure (_PKI_)::
A set of roles, policies, and procedures needed to create, manage, distribute, use, store, and revoke xref:security/ssl-framework.adoc#term-ssl-certificate[digital certificates] and manage xref:security/ssl-framework.adoc#term-ssl-public-key[public-key] encryption.

[[term-ssl-public-key]]public key::
The public key can be obtained and used by anyone to encrypt messages intended for a particular recipient.
This is also referred to as the xref:security/ssl-framework.adoc#term-ssl-certificate[certificate].

[[term-ssl-tls-protocol]]TLS protocol::
The cryptographic protocol that provides communications security over a computer network.
The Transport Layer Security (TLS) protocol and its predecessor, the Secure Sockets Layer (SSL) protocol are both frequently referred to as "SSL".

[[term-ssl-TLS-version]]TLS version::
A version of the TLS protocol.
