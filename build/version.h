namespace android {
    namespace build {
        std::string GetBuildNumber()
        {
            return CORE_GIT_REV;
        }
    }
}
