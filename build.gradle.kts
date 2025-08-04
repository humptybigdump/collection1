plugins {
    id("java")
    id("antlr")
    id("application")
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:5.9.1"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    antlr("org.antlr:antlr4:4.5.3")
}

tasks.test {
    useJUnitPlatform()
}

application {
    mainClass = "Main"
}

