import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/edit_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_list_response.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';

abstract class CreateOrganizationInterface {
  Future<Organization> createOrganization(CreateOrganizationRequest org);

  Future<Organization> editOrganization(EditOrganizationRequest org, int id);

  Future<OrganizationListResponse> getManagersOrganizations({
    int page = 0,
    int size = 5,
  });

  Future<OrganizationListResponse> getAllOrganizations({
    int page = 0,
    int size = 8,
    String? name,
    String? city,
  });

  Future<Organization> deleteOrganization(int id);

  Future<Organization> getOrganizationById(int id);
}
