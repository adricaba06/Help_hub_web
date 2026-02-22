import 'package:help_hup_mobile/core/models/organization/create_organization_request.dart';
import 'package:help_hup_mobile/core/models/organization/organization_list_response.dart';
import 'package:help_hup_mobile/core/models/organization/organization_response.dart';

abstract class CreateOrganizationInterface {
  Future<Organization> createOrganization(CreateOrganizationRequest org);

  Future<OrganizationListResponse> getManagersOrganizations({int page =0, int size =5});

  Future<Organization> deleteOrganization(int id);

  Future<Organization> getOrganizationById(int id);
}


