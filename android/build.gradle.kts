import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// flutter_webrtc 0.12.x still declares compileSdkVersion 31 in its own
// legacy Gradle file. Its modern AndroidX transitive dependencies require 34.
// Keep the correction in this project rather than editing the Pub cache.
subprojects {
    if (name == "flutter_webrtc") {
        pluginManager.withPlugin("com.android.library") {
            extensions.configure<LibraryExtension> {
                compileSdk = 34
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
