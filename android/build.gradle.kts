allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            val clazz = androidExt.javaClass
            try {
                clazz.getMethod("compileSdkVersion", Int::class.java).invoke(androidExt, 36)
            } catch (e: Exception) {
                try {
                    clazz.getMethod("setCompileSdkVersion", Int::class.java).invoke(androidExt, 36)
                } catch (e2: Exception) {}
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
