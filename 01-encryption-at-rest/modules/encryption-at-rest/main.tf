# Create Project
resource "mongodbatlas_project" "create_project" {
  name   = "jpmctest_0"
  org_id = var.mongodb_atlas_org_id
}


# Create Setup for Role Authorization
resource "mongodbatlas_cloud_provider_access_setup" "project_cloud_provider_access" {
  project_id    = mongodbatlas_project.create_project.id
  provider_name = "AWS"
}


# Create Role in AWS
resource "aws_iam_role" "project_cmk_role" {
  name = "app-jpmctest-0-cmk-role-mongodb"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = mongodbatlas_cloud_provider_access_setup.project_cloud_provider_access.aws.atlas_aws_account_arn
        }
        Condition = {
            StringEquals = {
                "sts:ExternalId" = mongodbatlas_cloud_provider_access_setup.project_cloud_provider_access.aws.atlas_assumed_role_external_id
            }
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}


# Authorize Role
resource "mongodbatlas_cloud_provider_access_authorization" "project_cloud_provider_access_authorization" {
  depends_on = [ aws_iam_role.project_cmk_role ]
  project_id = mongodbatlas_project.create_project.id
  role_id    = mongodbatlas_cloud_provider_access_setup.project_cloud_provider_access.role_id

  aws {
    iam_assumed_role_arn = aws_iam_role.project_cmk_role.arn
  }
}


# Enable Encryption-at-Rest
resource "mongodbatlas_encryption_at_rest" "encryption" {
  depends_on = [
    mongodbatlas_cloud_provider_access_authorization.project_cloud_provider_access_authorization,
    aws_kms_grant.project_cmk_permissions
  ]

  project_id = mongodbatlas_project.create_project.id

  aws_kms_config {
    enabled                = true
    customer_master_key_id = aws_kms_key.project_cmk.key_id
    region                 = upper(replace(var.aws_region, "-", "_"))
    role_id                = mongodbatlas_cloud_provider_access_setup.project_cloud_provider_access.role_id
  }
}


# Enable Auditing
resource "mongodbatlas_auditing" "auditing" {
  project_id                  = mongodbatlas_project.create_project.id
  audit_filter                = "{'$or':[{'users':[]},{'$and':[{'$or':[{'users':{'$elemMatch':{'$or':[{'db':'admin'},{'db':'$external'}]}}},{'roles':{'$elemMatch':{'$or':[{'db':'admin'}]}}}]},{'$or':[{'atype':'authCheck','param.command':{'$in':['aggregate','count','distinct','group','mapReduce','geoNear','geoSearch','eval','find','getLastError','getMore','getPrevError','parallelCollectionScan','delete','findAndModify','insert','update','resetError']}},{'atype':{'$in':['authenticate','createCollection','createDatabase','createIndex','renameCollection','dropCollection','dropDatabase','dropIndex','createUser','dropUser','dropAllUsersFromDatabase','updateUser','grantRolesToUser','revokeRolesFromUser','createRole','updateRole','dropRole','dropAllRolesFromDatabase','grantRolesToRole','revokeRolesFromRole','grantPrivilegesToRole','revokePrivilegesFromRole','enableSharding','shardCollection','addShard','removeShard','shutdown','applicationMessage']}}]}]}]}"
  audit_authorization_success = false
  enabled                     = true
}


# Generate KMS key
resource "aws_kms_key" "project_cmk" {
  description         = "KMS Key for MongoDB Atlas: App jpmctest-0 project jpmctest-0"
  enable_key_rotation = true

  tags = {
    tag-key = "tag-value"
  }
}


# Grant Key
resource "aws_kms_grant" "project_cmk_permissions" {
  name              = "grant-encryption-operations-jpmctest-0"
  key_id            = aws_kms_key.project_cmk.id
  grantee_principal = aws_iam_role.project_cmk_role.arn
  operations        = ["Encrypt", "Decrypt", "DescribeKey"]
}
