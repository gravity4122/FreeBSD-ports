#-*- mode: Fundamental; tab-width: 4; -*-
# ex:ts=4
#
# bsd.java.mk - Support for Java-based ports.
#
# Created by: Ernst de Haan <znerd@FreeBSD.org>
#
# For FreeBSD committers:
# Please send all suggested changes to the maintainer instead of committing
# them to CVS yourself.
#
# $FreeBSD$
#

.if !defined(Java_Include)

Java_Include=				bsd.java.mk
Java_Include_MAINTAINER=	znerd@FreeBSD.org

#
# Variables that each port can define:
#
# USE_JAVA			Should be defined to the remaining variables to have any
#					effect
#
# JAVA_VERSION		List of space-separated suitable java versions for the
#					port. An optional "+" allows you to specify a range of
#					versions. (allowed values: 1.1[+] 1.2[+] 1.3[+] 1.4[+])
#
# JAVA_OS			List of space-separated suitable JDK port operating systems
#					for the port. (allowed values: native linux)
#
# JAVA_VENDOR		List of space-separated suitable JDK port vendors for the
#					port. (allowed values: freebsd bsdjava sun ibm blackdown)
#
# JAVA_BUILD		When set, it means that the selected JDK port should be
#					added to build dependencies for the port.
#
# JAVA_RUN			This variable works exactly the same as JAVA_BUILD but
#					regarding run dependencies.
#
# USE_JIKES			Whether the port should or should not use jikes(1) to build.
#
# Variables defined for the port:
#
# JAVA_PORT			The name of the JDK port. (e.g. 'java/jdk14')
#
# JAVA_PORT_VERSION	The version of the JDK port. (e.g. '1.4')
#
# JAVA_PORT_OS		The operating system used by the JDK port. (e.g. 'linux')
#
# JAVA_PORT_VENDOR	The vendor of the JDK port. (e.g. 'sun')
#
# JAVA_PORT_OS_DESCRIPTION		Description of the operating system used by the
#								JDK port. (e.g. 'Linux')
#
# JAVA_PORT_VENDOR_DESCRIPTION	Description of the vendor of the JDK port.
#								(e.g. 'FreeBSD Foundation')
#
# JAVA_HOME			Path to the installation directory of the JDK. (e.g.
#					'/usr/local/jdk1.3.1')
#
# JAVAC				Path to the Java compiler to use. (e.g.
#					'/usr/local/jdk1.1.8/bin/javac' or '/usr/local/bin/jikes')
#
# JAR				Path to the JAR tool to use. (e.g.
#					'/usr/local/jdk1.2.2/bin/jar' or '/usr/local/bin/fastjar')
#
# APPLETVIEWER		Path to the appletviewer utility. (e.g.
#					'/usr/local/linux-jdk1.2.2/bin/appletviewer')
#
# JAVA				Path to the java executable. Use this for executing Java
#					programs. (e.g. '/usr/local/jdk1.3.1/bin/java')
#
# JAVADOC			Path to the javadoc utility program.
#
# JAVAH				Path to the javah program.
#
# JAVAP				Path to the javap program.
#
# JAVA_KEYTOOL		Path to the keytool utility program. This settings is
#					availble only if the JDK is Java 1.2 or higher.
#
# JAVA_N2A			Path to the native2ascii tool.
#
# JAVA_POLICYTOOL	Path to the policytool program. This variable is available
#					only if the JDK is Java 1.2 or higher.
#
# JAVA_SERIALVER	Path to the serialver utility program.
#
# RMIC				Path to the RMI stub/skeleton generator, rmic.
#
# RMIREGISTRY		Path to the RMI registry program, rmiregistry.
#
# RMID				Path to the RMI daemon program. This settings is only
#					available if the JDK is Java 1.2 or higher.
#
# JAVA_CLASSES		Path to the archive that contains the JDK class files. On
#					JDK 1.2 or later, this is ${JAVA_HOME}/jre/lib/rt.jar.
#					Earlier JDK's use ${JAVA_HOME/lib/classes.zip.
#

#
# There are the following stages:
#
# Stage 1: Define constants
# Stage 2: Deal with JAVA_HOME if it is already set
# Stage 3: Determine which JDK ports are installed
# Stage 4: Determine which JDK ports are suitable
# Stage 5: Decide the exact JDK to use (or install)
# Stage 6: Define all settings for the port to use
# Stage 7: Add any dependencies if necessary
#

.	if defined(USE_JAVA)


#-----------------------------------------------------------------------------
# Stage 1: Define constants
#

# System-global directories
JAVASHAREDIR?=	${PREFIX}/share/java
JAVAJARDIR?=	${JAVASHAREDIR}/classes

# The complete list of Java versions, os and vendors supported.
_JAVA_VERSIONS=		1.1 1.2 1.3 1.4
_JAVA_VERSIONS_ALL=	${_JAVA_VERSIONS} ${_JAVA_VERSIONS:S/$/+/}
_JAVA_OS_LIST=		native linux
_JAVA_VENDORS=		freebsd bsdjava sun blackdown ibm

# Set all meta-information about JDK ports:
# port location, corresponding JAVA_HOME, JDK version, OS, vendor
_JAVA_PORT_NATIVE_FREEBSD_JDK_1_3_INFO=		java/diablo-jdk13			${LOCALBASE}/diablo-jdk1.3.1			1.3	native	freebsd
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1_INFO=		java/jdk11					${LOCALBASE}/jdk1.1.8					1.1	native	bsdjava
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2_INFO=		java/jdk12					${LOCALBASE}/jdk1.2.2					1.2	native	bsdjava
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3_INFO=		java/jdk13					${LOCALBASE}/jdk1.3.1					1.3	native	bsdjava
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4_INFO=		java/jdk14					${LOCALBASE}/jdk1.4.2					1.4	native	bsdjava
_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2_INFO=	java/linux-blackdown-jdk12	${LOCALBASE}/linux-blackdown-jdk1.2.2	1.2	linux	blackdown
_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3_INFO=	java/linux-blackdown-jdk13	${LOCALBASE}/linux-blackdown-jdk1.3.1	1.3	linux	blackdown
_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4_INFO=	java/linux-blackdown-jdk14	${LOCALBASE}/linux-blackdown-jdk1.4.2	1.3	linux	blackdown
_JAVA_PORT_LINUX_IBM_JDK_1_3_INFO=			java/linux-ibm-jdk13		${LOCALBASE}/linux-ibm-jdk1.3.1			1.3	linux	ibm
_JAVA_PORT_LINUX_IBM_JDK_1_4_INFO=			java/linux-ibm-jdk14		${LOCALBASE}/linux-ibm-jdk1.4.1			1.4	linux	ibm
_JAVA_PORT_LINUX_SUN_JDK_1_2_INFO=			java/linux-sun-jdk12		${LOCALBASE}/linux-sun-jdk1.2.2			1.2	linux	sun
_JAVA_PORT_LINUX_SUN_JDK_1_3_INFO=			java/linux-sun-jdk13		${LOCALBASE}/linux-sun-jdk1.3.1			1.3	linux	sun
_JAVA_PORT_LINUX_SUN_JDK_1_4_INFO=			java/linux-sun-jdk14		${LOCALBASE}/linux-sun-jdk1.4.2			1.4	linux	sun

_JAVA_VENDOR_freebsd=		"FreeBSD Foundation"
_JAVA_VENDOR_bsdjava=		"BSD Java Porting Team"
_JAVA_VENDOR_blackdown=		Blackdown
_JAVA_VENDOR_ibm=			IBM
_JAVA_VENDOR_sun=			Sun

_JAVA_OS_native=	Native
_JAVA_OS_linux=		Linux

# Set the JAVA_HOME directories for all recognized JDK's
_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_1!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_2!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_3!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_4!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_NATIVE_FREEBSD_JDK_1_3!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_FREEBSD_JDK_1_3_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_2!=	${ECHO_CMD} "${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_3!=	${ECHO_CMD} "${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_4!=	${ECHO_CMD} "${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_IBM_JDK_1_3!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_IBM_JDK_1_3_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_IBM_JDK_1_4!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_IBM_JDK_1_4_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_SUN_JDK_1_2!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_SUN_JDK_1_2_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_SUN_JDK_1_3!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_SUN_JDK_1_3_INFO}" | ${AWK} '{ print $$2 }'
_JAVA_HOME_LINUX_SUN_JDK_1_4!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_SUN_JDK_1_4_INFO}" | ${AWK} '{ print $$2 }'

# Set the JDK ports for all recognized JDK's
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_NATIVE_FREEBSD_JDK_1_3!=		${ECHO_CMD} "${_JAVA_PORT_NATIVE_FREEBSD_JDK_1_3_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2!=	${ECHO_CMD} "${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3!=	${ECHO_CMD} "${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4!=	${ECHO_CMD} "${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_IBM_JDK_1_3!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_IBM_JDK_1_3_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_IBM_JDK_1_4!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_IBM_JDK_1_4_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_SUN_JDK_1_2!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_SUN_JDK_1_2_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_SUN_JDK_1_3!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_SUN_JDK_1_3_INFO}" | ${AWK} '{ print $$1 }'
_JAVA_PORT_LINUX_SUN_JDK_1_4!=			${ECHO_CMD} "${_JAVA_PORT_LINUX_SUN_JDK_1_4_INFO}" | ${AWK} '{ print $$1 }'

# Set the name of the file that indicates that a JDK is indeed installed, as a
# relative path within the JAVA_HOME directory.
_JDK_FILE=bin/javac

# Set the path to Jikes and define the Jikes dependency
_JIKES_PATH=	${LOCALBASE}/bin/jikes
_DEPEND_JIKES=	${_JIKES_PATH}:${PORTSDIR}/java/jikes

#-----------------------------------------------------------------------------
# Stage 2: Determine which JDK ports are installed
#

.		undef _JAVA_PORTS_INSTALLED

.		if exists(${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_1}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1
.		endif
.		if exists(${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_2}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2
.		endif
.		if exists(${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_3}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3
.		endif
.		if exists(${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_4}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4
.		endif
.		if exists(${_JAVA_HOME_NATIVE_FREEBSD_JDK_1_3}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_NATIVE_FREEBSD_JDK_1_3
.		endif
.		if exists(${_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_2}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2
.		endif
.		if exists(${_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_3}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3
.		endif
.		if exists(${_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_4}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4
.		endif
.		if exists(${_JAVA_HOME_LINUX_IBM_JDK_1_3}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_IBM_JDK_1_3
.		endif
.		if exists(${_JAVA_HOME_LINUX_IBM_JDK_1_4}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_IBM_JDK_1_4
.		endif
.		if exists(${_JAVA_HOME_LINUX_SUN_JDK_1_2}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_SUN_JDK_1_2
.		endif
.		if exists(${_JAVA_HOME_LINUX_SUN_JDK_1_3}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_SUN_JDK_1_3
.		endif
.		if exists(${_JAVA_HOME_LINUX_SUN_JDK_1_4}/${_JDK_FILE})
_JAVA_PORTS_INSTALLED+=		JAVA_PORT_LINUX_SUN_JDK_1_4
.		endif


#-----------------------------------------------------------------------------
# Stage 3: Deal with JAVA_HOME if it is already set
#

# See if JAVA_HOME points to a known JDK. If it does, then undefine JAVA_HOME
# and actually use JAVA_PORT instead, so that we do not screw with our
# dependencies.
.		if defined(JAVA_HOME)
_JAVA_HOME=	${JAVA_HOME}
.			undef(JAVA_HOME)
.			if ${_JAVA_HOME} == ${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_1}
JAVA_PORT=	${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_2}
JAVA_PORT=	${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_3}
JAVA_PORT=	${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_NATIVE_BSDJAVA_JDK_1_4}
JAVA_PORT=	${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_NATIVE_FREEBSD_JDK_1_3}
JAVA_PORT=	${_JAVA_PORT_NATIVE_FREEBSD_JDK_1_3}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_2}
JAVA_PORT=	${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_3}
JAVA_PORT=	${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_BLACKDOWN_JDK_1_4}
JAVA_PORT=	${_JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_IBM_JDK_1_3}
JAVA_PORT=	${_JAVA_PORT_LINUX_IBM_JDK_1_3}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_IBM_JDK_1_4}
JAVA_PORT=	${_JAVA_PORT_LINUX_IBM_JDK_1_4}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_SUN_JDK_1_2}
JAVA_PORT=	${_JAVA_PORT_LINUX_SUN_JDK_1_2}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_SUN_JDK_1_3}
JAVA_PORT=	${_JAVA_PORT_LINUX_SUN_JDK_1_3}
.			elif ${_JAVA_HOME} == ${_JAVA_HOME_LINUX_SUN_JDK_1_4}
JAVA_PORT=	${_JAVA_PORT_LINUX_SUN_JDK_1_4}
.			else
JAVA_HOME=	${_JAVA_HOME}
.			endif
.		endif


#-----------------------------------------------------------------------------
# Stage 4: Determine which JDK ports are suitable
#

# First detect if we are using bsd.java.mk v1.0
_USE_BSD_JAVA_MK_1_0!=	${ECHO_CMD} "${_JAVA_VERSIONS_ALL}" \
						| ${TR} " " "\n" \
						| ${GREP} -q "^${USE_JAVA}$$" && ${ECHO_CMD} "yes" || ${ECHO_CMD} "no"
.		if (${_USE_BSD_JAVA_MK_1_0} == "yes") && !defined(JAVA_VERSION)
# Then affect the variables so that we may use v2.0
JAVA_VERSION=	${USE_JAVA}
.		endif
# From here, the port is using bsd.java.mk v2.0

# List JDK ports by version
_JAVA_PORTS_1_4= JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4 \
				 JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4 \
				 JAVA_PORT_LINUX_SUN_JDK_1_4 \
				 JAVA_PORT_LINUX_IBM_JDK_1_4
_JAVA_PORTS_1_3= JAVA_PORT_NATIVE_FREEBSD_JDK_1_3 \
				 JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3 \
				 JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3 \
				 JAVA_PORT_LINUX_SUN_JDK_1_3 \
				 JAVA_PORT_LINUX_IBM_JDK_1_3
_JAVA_PORTS_1_2= JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2 \
				 JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2 \
				 JAVA_PORT_LINUX_SUN_JDK_1_2
_JAVA_PORTS_1_1= JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1

# List JDK ports by OS
_JAVA_PORTS_NATIVE=	JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1 \
					JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2 \
					JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3 \
					JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4 \
					JAVA_PORT_NATIVE_FREEBSD_JDK_1_3
_JAVA_PORTS_LINUX=	JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2 \
					JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3 \
					JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4 \
					JAVA_PORT_LINUX_IBM_JDK_1_3 \
					JAVA_PORT_LINUX_IBM_JDK_1_4 \
					JAVA_PORT_LINUX_SUN_JDK_1_2 \
					JAVA_PORT_LINUX_SUN_JDK_1_3 \
					JAVA_PORT_LINUX_SUN_JDK_1_4

# List JDK ports by vendor
_JAVA_PORTS_FREEBSD= JAVA_PORT_NATIVE_FREEBSD_JDK_1_3
_JAVA_PORTS_BSDJAVA= JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1 \
					 JAVA_PORT_NATIVE_BSDJAVA_JDK_1_2 \
					 JAVA_PORT_NATIVE_BSDJAVA_JDK_1_3 \
					 JAVA_PORT_NATIVE_BSDJAVA_JDK_1_4
_JAVA_PORTS_BLACKDOWN= JAVA_PORT_LINUX_BLACKDOWN_JDK_1_2 \
					   JAVA_PORT_LINUX_BLACKDOWN_JDK_1_3 \
					   JAVA_PORT_LINUX_BLACKDOWN_JDK_1_4
_JAVA_PORTS_SUN= JAVA_PORT_LINUX_SUN_JDK_1_2 \
				 JAVA_PORT_LINUX_SUN_JDK_1_3 \
				 JAVA_PORT_LINUX_SUN_JDK_1_4
_JAVA_PORTS_IBM= JAVA_PORT_LINUX_IBM_JDK_1_3 \
				 JAVA_PORT_LINUX_IBM_JDK_1_4

# List all JDK ports
_JAVA_PORTS_ALL= ${_JAVA_PORTS_1_1} \
				 ${_JAVA_PORTS_1_2} \
				 ${_JAVA_PORTS_1_3} \
				 ${_JAVA_PORTS_1_4}

# Build the list of possible JDK ports by version
.		if defined(JAVA_VERSION)
_JAVA_VERSION=	${JAVA_VERSION:S/1.1+/1.1 1.2 1.3 1.4/:S/1.2+/1.2 1.3 1.4/:S/1.3+/1.3 1.4/:S/1.4+/1.4/}
.			undef(_JAVA_PORTS_BY_VERSION)
.			if ${_JAVA_VERSION:M1.1} == "1.1"
_JAVA_PORTS_BY_VERSION+= ${_JAVA_PORTS_1_1}
.			endif
.			if ${_JAVA_VERSION:M1.2} == "1.2"
_JAVA_PORTS_BY_VERSION+= ${_JAVA_PORTS_1_2}
.			endif
.			if ${_JAVA_VERSION:M1.3} == "1.3"
_JAVA_PORTS_BY_VERSION+= ${_JAVA_PORTS_1_3}
.			endif
.			if ${_JAVA_VERSION:M1.4} == "1.4"
_JAVA_PORTS_BY_VERSION+= ${_JAVA_PORTS_1_4}
.			endif
.			if !defined(_JAVA_PORTS_BY_VERSION)
.BEGIN:
	@${ECHO_CMD} "${PKGNAME}: \"${JAVA_VERSION}\" is not a valid value for JAVA_VERSION. It should be one or more of: ${_JAVA_VERSIONS} (with an optional \"+\" suffix.)";
	@${FALSE}
.			endif
.		else
_JAVA_PORTS_BY_VERSION= ${_JAVA_PORTS_ALL}
.		endif

# Build the list of possible JDK ports by OS
.		if defined(JAVA_OS)
.			undef(_JAVA_PORTS_BY_OS)
.			if ${JAVA_OS:Mnative} == "native"
_JAVA_PORTS_BY_OS+= ${_JAVA_PORTS_NATIVE}
.			endif
.			if ${JAVA_OS:Mlinux} == "linux"
_JAVA_PORTS_BY_OS+= ${_JAVA_PORTS_LINUX}
.			endif
.			if !defined(_JAVA_PORTS_BY_OS)
.BEGIN:
	@${ECHO_CMD} "${PKGNAME}: \"${JAVA_OS}\" is not a valid value for JAVA_OS. It should be one or more of: ${_JAVA_OS_LIST}";
	@${FALSE}
.			endif
.		else
_JAVA_PORTS_BY_OS= ${_JAVA_PORTS_ALL}
.		endif

# Build the list of possible JDK ports by vendor
.		if defined(JAVA_VENDOR)
.			undef(_JAVA_PORTS_BY_VENDOR)
.			if ${JAVA_VENDOR:Mfreebsd} == "freebsd"
_JAVA_PORTS_BY_VENDOR+= ${_JAVA_PORTS_FREEBSD}
.			endif
.			if ${JAVA_VENDOR:Mbsdjava} == "bsdjava"
_JAVA_PORTS_BY_VENDOR+= ${_JAVA_PORTS_BSDJAVA}
.			endif
.			if ${JAVA_VENDOR:Mblackdown} == "blackdown"
_JAVA_PORTS_BY_VENDOR+= ${_JAVA_PORTS_BLACKDOWN}
.			endif
.			if ${JAVA_VENDOR:Msun} == "sun"
_JAVA_PORTS_BY_VENDOR+= ${_JAVA_PORTS_SUN}
.			endif
.			if ${JAVA_VENDOR:Mibm} == "ibm"
_JAVA_PORTS_BY_VENDOR+= ${_JAVA_PORTS_IBM}
.			endif
.			if !defined(_JAVA_PORTS_BY_VENDOR)
.BEGIN:
	@${ECHO_CMD} "${PKGNAME}: \"${JAVA_VENDOR}\" is not a valid value for JAVA_VENDOR. It should be one or more of: ${_JAVA_VENDORS}";
	@${FALSE}
.			endif
.		else
_JAVA_PORTS_BY_VENDOR= ${_JAVA_PORTS_ALL}
.		endif

_MY_JAVA_PORTS:=		${_JAVA_PORTS_ALL:S/^/\${_/:S/$/_INFO} @ /}

# Build the list of possible JDK ports by version, OS and vendor
_JAVA_PORTS_BY_VERSION!=	${ECHO_CMD} "${_JAVA_PORTS_BY_VERSION}" | ${TR} " " "\n" | ${SORT} | /usr/bin/uniq
_JAVA_PORTS_BY_OS!=			${ECHO_CMD} "${_JAVA_PORTS_BY_OS}" | ${TR} " " "\n" | ${SORT} | /usr/bin/uniq
_JAVA_PORTS_BY_VENDOR!=		${ECHO_CMD} "${_JAVA_PORTS_BY_VENDOR}" | ${TR} " " "\n" | ${SORT} | /usr/bin/uniq
_JAVA_PORTS_POSSIBLE!=		${ECHO_CMD} "${_JAVA_PORTS_BY_VERSION} ${_JAVA_PORTS_BY_OS} ${_JAVA_PORTS_BY_VENDOR}" \
							| ${TR} " " "\n" \
							| ${SORT} -r \
							| /usr/bin/uniq -c \
							| ${SED} "s/^\( *\)//" \
							| ${GREP} "^3 " \
							| ${AWK} '{ print $$2 }'

#-----------------------------------------------------------------------------
# Stage 5: Decide the exact JDK to use (or install)
#

# Find an installed JDK port that matches the requirements of the port
_JAVA_PORTS_INSTALLED_POSSIBLE!=	${ECHO_CMD} "${_JAVA_PORTS_POSSIBLE} ${_JAVA_PORTS_INSTALLED}" \
									| ${TR} " " "\n" \
									| ${SORT} -r \
									| /usr/bin/uniq -c \
									| ${SED} "s/^\( *\)//" \
									| ${GREP} "^2 " \
									| ${AWK} '{ print $$2 }'
.		if ${_JAVA_PORTS_INSTALLED_POSSIBLE} != ""
_JAVA_PORT!=	${ECHO_CMD} "${_JAVA_PORTS_INSTALLED_POSSIBLE}" \
				| ${AWK} '{ print $$1 }'

# If no installed JDK port fits, then pick one from the list of possible ones
.		else
_JAVA_PORT!=	${ECHO_CMD} "${_JAVA_PORTS_POSSIBLE}" \
				| ${AWK} '{ print $$1 }'
.		endif
_JAVA_PORT_INFO:=	${_JAVA_PORT:S/^/\${_/:S/$/_INFO}/}
JAVA_PORT!=				${ECHO_CMD} "${_JAVA_PORT_INFO}" | ${AWK} '{ print $$1 }'
JAVA_HOME!=				${ECHO_CMD} "${_JAVA_PORT_INFO}" | ${AWK} '{ print $$2 }'
JAVA_PORT_VERSION!=		${ECHO_CMD} "${_JAVA_PORT_INFO}" | ${AWK} '{ print $$3 }'
JAVA_PORT_OS!=			${ECHO_CMD} "${_JAVA_PORT_INFO}" | ${AWK} '{ print $$4 }'
JAVA_PORT_VENDOR!=		${ECHO_CMD} "${_JAVA_PORT_INFO}" | ${AWK} '{ print $$5 }'

JAVA_PORT_VENDOR_DESCRIPTION:=	${JAVA_PORT_VENDOR:S/^/\${_JAVA_VENDOR_/:S/$/}/}
JAVA_PORT_OS_DESCRIPTION:=		${JAVA_PORT_OS:S/^/\${_JAVA_OS_/:S/$/}/}

# Debug target
# (will probably get removed in the final version)
java-debug:
	@${ECHO_CMD} "_USE_BSD_JAVA_MK_1_0=           ${_USE_BSD_JAVA_MK_1_0}"
	@${ECHO_CMD}
	@${ECHO_CMD} "# User specified parameters:"
	@${ECHO_CMD} "JAVA_VERSION=                   ${JAVA_VERSION}	(${_JAVA_VERSION})"
	@${ECHO_CMD} "JAVA_OS=                        ${JAVA_OS}"
	@${ECHO_CMD} "JAVA_VENDOR=                    ${JAVA_VENDOR}"
	@${ECHO_CMD}
	@${ECHO_CMD} "# JDK port dependency selection process:"
	@${ECHO_CMD} "_JAVA_PORTS_POSSIBLE=           ${_JAVA_PORTS_POSSIBLE}"
	@${ECHO_CMD} "_JAVA_PORTS_INSTALLED=          ${_JAVA_PORTS_INSTALLED}"
	@${ECHO_CMD} "_JAVA_PORTS_INSTALLED_POSSIBLE= ${_JAVA_PORTS_INSTALLED_POSSIBLE}"
	@${ECHO_CMD} "_JAVA_PORT=                     ${_JAVA_PORT}"
	@${ECHO_CMD} "_JAVA_PORT_INFO=                ${_JAVA_PORT_INFO:S/\t/ /}"
	@${ECHO_CMD}
	@${ECHO_CMD} "# Selected JDK port:"
	@${ECHO_CMD} "JAVA_PORT=                      ${JAVA_PORT}"
	@${ECHO_CMD} "JAVA_HOME=                      ${JAVA_HOME}"
	@${ECHO_CMD} "JAVA_PORT_VERSION=              ${JAVA_PORT_VERSION}"
	@${ECHO_CMD} "JAVA_PORT_OS=                   ${JAVA_PORT_OS}	(${JAVA_PORT_OS_DESCRIPTION})"
	@${ECHO_CMD} "JAVA_PORT_VENDOR=               ${JAVA_PORT_VENDOR}	(${JAVA_PORT_VENDOR_DESCRIPTION})"

#-----------------------------------------------------------------------------
# Stage 6: Define all settings for the port to use

# At this stage both JAVA_HOME and JAVA_PORT are definitely given a value.

# Define the location of the Java compiler. If USE_JIKES is set to YES, then
# use Jikes. If USE_JIKES is set to NO, then don't use it. If it is set to a
# different value, then fail with an error message. Otherwise USE_JIKES is not
# set, in which case it is checked if Jikes is already installed. If it is,
# then it will be used, otherwise it will not be used.

# Only define JAVAC if NEED_JAVAC is defined
.		undef JAVAC

# The default value for NEED_JAVAC is temporarily (!) YES
# This will change as soon as the affecting ports have NEED_JAVAC=YES
.		if !defined(NEED_JAVAC)
NEED_JAVAC=	NO
.		endif

.		if (${NEED_JAVAC} == "YES") || (${NEED_JAVAC} == "yes")
.			if defined(USE_JIKES)
.				if (${USE_JIKES} == "YES") || (${USE_JIKES} == "yes")
JAVAC=		${_JIKES_PATH}
WITH_JIKES=	YES
.				elif !((${USE_JIKES} == "NO") || (${USE_JIKES} == "no"))
.BEGIN:
	@${ECHO_CMD} "${PKGNAME}: \"${USE_JIKES}\" is not a valid value for USE_JIKES. It should be YES or NO, or it should be undefined.";
	@${FALSE}
.				endif
.			elif exists(${_JIKES_PATH}) && !defined(NO_BUILD)
JAVAC=		${_JIKES_PATH}
WITH_JIKES=	YES
.			endif
.			if !defined(JAVAC)
JAVAC=	${JAVA_HOME}/bin/javac
.			endif
.		endif

# Define the location of some more executables.
APPLETVIEWER=	${JAVA_HOME}/bin/appletviewer
JAR=			${JAVA_HOME}/bin/jar
JAVA=			${JAVA_HOME}/bin/java
JAVADOC=		${JAVA_HOME}/bin/javadoc
JAVAH=			${JAVA_HOME}/bin/javah
JAVAP=			${JAVA_HOME}/bin/javap
JAVA_N2A=		${JAVA_HOME}/bin/native2ascii
JAVA_SERIALVER=	${JAVA_HOME}/bin/serialver
RMIC=			${JAVA_HOME}/bin/rmic
RMIREGISTRY=	${JAVA_HOME}/bin/rmiregistry

# Some executables only exists in JDK 1.2 and up
.		if ${JAVA_PORT} != ${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1}
JAVA_KEYTOOL=		${JAVA_HOME}/bin/keytool
JAVA_POLICYTOOL=	${JAVA_HOME}/bin/policytool
RMID=				${JAVA_HOME}/bin/rmid
.		endif

# Set the location of the ZIP or JAR file with all standard Java classes.
.		if ${JAVA_PORT} == ${_JAVA_PORT_NATIVE_BSDJAVA_JDK_1_1}
JAVA_CLASSES=	${JAVA_HOME}/lib/classes.zip
.		else
JAVA_CLASSES=	${JAVA_HOME}/jre/lib/rt.jar
.		endif


#-----------------------------------------------------------------------------
# Stage 7: Add any dependencies if necessary

# Possibly add Jikes to the dependencies
.		if defined(JAVAC) && (${JAVAC} == ${_JIKES_PATH})
.			if !defined(NO_BUILD_DEPENDS_JAVA)
BUILD_DEPENDS+=		${_DEPEND_JIKES}
.			endif
.			if !defined(NO_RUN_DEPENDS_JAVA)
RUN_DEPENDS+=		${_DEPEND_JIKES}
.			endif
.		endif

# Add the JDK port to the dependencies
.		if defined(NO_BUILD_DEPENDS_JAVA) && defined(NO_RUN_DEPENDS_JAVA)
.BEGIN:
	@${ECHO_CMD} "${PKGNAME}: NO_BUILD_DEPENDS_JAVA and NO_RUN_DEPENDS_JAVA cannot be set at the same time.";
	@${FALSE}
.		endif
.		if defined(JAVA_BUILD) && defined(NO_BUILD)
.BEGIN:
	@${ECHO_CMD} "${PKGNAME}: JAVA_BUILD and NO_BUILD cannot be set at the same time.";
	@${FALSE}
.		endif
_DEPEND_JAVA=	${JAVA}:${PORTSDIR}/${JAVA_PORT}
.		if !defined(JAVA_EXTRACT) && !defined(JAVA_BUILD) && !defined(JAVA_RUN)
# In general, an EXTRACT_DEPENDS on java is not wanted, so only
# automatically set up BUILD_DEPENDS and RUN_DEPENDS
.			if !defined(NO_BUILD_DEPENDS_JAVA) && !defined(NO_BUILD)
BUILD_DEPENDS+=		${_DEPEND_JAVA}
.			endif
.			if !defined(NO_RUN_DEPENDS_JAVA)
RUN_DEPENDS+=		${_DEPEND_JAVA}
.			endif
.		else
.			if defined(JAVA_EXTRACT)
EXTRACT_DEPENDS+=	${_DEPEND_JAVA}
.			endif
.			if defined(JAVA_BUILD)
BUILD_DEPENDS+=		${_DEPEND_JAVA}
.			endif
.			if defined(JAVA_RUN)
RUN_DEPENDS+=		${_DEPEND_JAVA}
.			endif
.		endif
.	endif
.endif
