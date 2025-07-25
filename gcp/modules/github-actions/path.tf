locals {
  # --- Path Calculation Logic ---

  # 1. Normalize path.root for cross-platform consistency (replace backslashes with forward slashes)
  normalized_path_root = replace(abspath(path.root), "\\", "/")

  # 2. Split path.root into individual directory components
  #    Example: "/home/user/my_project/terraform/envs/prod" -> ["", "home", "user", "my_project", "terraform", "envs", "prod"]
  path_components    = split("/", local.normalized_path_root)
  tf_source_dir_name = trimsuffix(local.tf_source_dir, "/")

  # 3. Find the index of the "terraform" directory in the path components.
  #    This assumes that all your Terraform modules are located within a directory named "terraform"
  #    that is a direct child of your project root.
  #    (e.g., if the module itself is at the project root).
  terraform_dir_index = index(local.path_components, "${local.tf_source_dir_name}")

  # 4. Determine the components that make up the absolute path to your project root.
  #    If 'terraform' directory is found: project root is the parent directory of 'terraform'.
  #    If 'terraform' directory is NOT found (index is -1): assume current path.root IS the project root.
  project_root_components = local.terraform_dir_index != -1 ? slice(local.path_components, 0, local.terraform_dir_index) : local.path_components

  # 5. Reconstruct the absolute path to the project root.
  project_root_dir = join("/", local.project_root_components)
}
