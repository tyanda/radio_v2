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
    // Only use the shared build directory for projects on the same drive/root
    // to avoid the "different roots" error on Windows when the pub cache is on C:
    val rootParentPath = rootProject.projectDir.parentFile.absolutePath
    val projectPath = project.projectDir.absolutePath
    if (projectPath.contains(rootParentPath)) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
