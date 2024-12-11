module "global_practice" {
  for_each        = local.project_vending_data_map
  source          = "../modules/folders"
  organization_id = each.value.settings.organization_id
  folder_name     = each.value.settings.names_gp
  parent_id       = each.value.settings.parent_id
}

module "poc" {
  for_each        = local.project_vending_data_map
  source          = "../modules/folders"
  organization_id = each.value.settings.organization_id
  folder_name     = each.value.settings.names_poc
  parent_id       = module.global_practice[each.key].folder_id
}

module "app_folder" {
  for_each        = local.project_vending_data_map
  source          = "../modules/folders"
  organization_id = each.value.settings.organization_id
  folder_name     = each.value.settings.names_app
  parent_id       = module.poc[each.key].folder_id
}


module "app_project" {
  for_each       = local.project_vending_data_map
  source         = "../modules/project_factory"
  project_name   = each.value.settings.project_name
  api            = each.value.settings.api
  folder_id      = module.app_folder[each.key].folder_id
  labels         = each.value.settings.labels
  owners_members = each.value.settings.owners_members
  depends_on = [
    module.app_folder
  ]
}

module "app_budget_alert" {
  for_each        = local.project_vending_data_map
  source          = "../modules/budget"
  project_name    = each.value.settings.project_name
  billing_id      = each.value.settings.billing_id
  project_no      = module.app_project[each.key].project_number
  approved_budget = each.value.settings.approved_budget
  members         = each.value.settings.notification_members
  depends_on = [
    module.app_project
  ]
}