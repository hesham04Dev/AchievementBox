allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir =  file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/$name")
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
